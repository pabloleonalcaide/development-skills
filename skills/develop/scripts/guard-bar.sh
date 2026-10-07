#!/usr/bin/env bash
# guard-bar.sh — flag diff lines that lower the quality bar.
# Usage: guard-bar.sh [base]   (default: the remote default branch, else main/master)
# Prints one "file:line: category: code" per suspect line, or "No findings". Always exits 0:
# the agent classifies each hit (justified → say so in the closing; unjustified → fix).
set -euo pipefail

base="${1:-}"
if [[ -z "$base" ]]; then
  base="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [[ -z "$base" ]]; then
    for b in main master; do git rev-parse --verify --quiet "$b" >/dev/null && base="$b" && break; done
  fi
fi
[[ -n "$base" ]] || { echo "guard-bar: cannot determine base branch; pass it as \$1" >&2; exit 2; }

TEST_FILE='(\.|_|/)(test|spec)s?(\.|/)|/__tests__/|/tests?/'
CONFIG_FILE='(jest|vitest|vite|nyc|c8|karma|tsconfig|biome|eslint|\.eslintrc|stryker|codecov|sonar|package)[^/]*\.(json|js|cjs|mjs|ts|ya?ml)$|\.nycrc|\.c8rc'

git diff --unified=0 --no-color "$base...HEAD" | awk -v test_re="$TEST_FILE" -v cfg_re="$CONFIG_FILE" '
  function strip(p) { if (p == "/dev/null") return p; return substr(p, 3) }
  function hit(f, l, cat, code) { sub(/^[+-][ \t]*/, "", code); printf "%s:%d: %s: %s\n", f, l, cat, code; n++ }
  function flush() {
    if (cur != "" && cur ~ test_re) {
      if (cur_new == "/dev/null") { printf "%s:0: deleted-test-file: whole file removed\n", cur; n++ }
      else if (rm_tests[cur] > add_tests[cur] || rm_asserts[cur] > add_asserts[cur])
        { printf "%s:0: fewer-tests-or-assertions: tests %+d, assertions %+d\n", cur, add_tests[cur] - rm_tests[cur], add_asserts[cur] - rm_asserts[cur]; n++ }
    }
  }
  /^diff --git/ { flush(); cur = ""; next }
  /^--- / { old = strip(substr($0, 5)); next }
  /^\+\+\+ / { file = strip(substr($0, 5)); cur_new = file; cur = (file == "/dev/null") ? old : file; next }
  /^@@/ { match($0, /\+[0-9]+/); line = substr($0, RSTART + 1, RLENGTH - 1) + 0; next }
  /^\+/ {
    c = $0
    if (c ~ /(^|[^a-zA-Z.])(it|test)(\.each)?\(/) add_tests[cur]++
    if (c ~ /expect\(|assert[A-Za-z]*\(/) add_asserts[cur]++
    if (c ~ /@ts-ignore|@ts-nocheck|@ts-expect-error/)                 hit(cur, line, "type-suppression", c)
    else if (c ~ /eslint-disable|biome-ignore|prettier-ignore|noqa|nosemgrep|gitleaks:allow|NOSONAR/) hit(cur, line, "lint-suppression", c)
    else if (c ~ /istanbul ignore|c8 ignore|v8 ignore|pragma: no cover/) hit(cur, line, "coverage-suppression", c)
    else if (c ~ /\.(skip|only|todo|fixme)\(|(^|[^a-zA-Z])x(it|describe|test)\(/) hit(cur, line, "skipped-or-focused-test", c)
    else if (c ~ /expect\.any\(|expect\.anything\(/)                   hit(cur, line, "loose-assertion", c)
    else if (c ~ /not implemented|NotImplemented|TODO: implement/)      hit(cur, line, "stub", c)
    else if (cur ~ cfg_re && c ~ /threshold|coverage|max[A-Z_-]|min[A-Z_-]|strict|noImplicit|bail|retries/) hit(cur, line, "config-bar-change", c)
    line++; next
  }
  /^-/ {
    c = $0
    if (c ~ /(^|[^a-zA-Z.])(it|test)(\.each)?\(/) rm_tests[cur]++
    if (c ~ /expect\(|assert[A-Za-z]*\(/) rm_asserts[cur]++
    next
  }
  END { flush(); if (n == 0) print "No findings" }
'
