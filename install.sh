#!/usr/bin/env bash
# Symlink every skill in this repo into your Claude Code skills directory.
# Usage: ./install.sh            (installs to ~/.claude/skills)
#        CLAUDE_SKILLS_DIR=... ./install.sh
set -euo pipefail

SRC="$(cd "$(dirname "$0")/skills" && pwd)"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
mkdir -p "$DEST"

for skill in "$SRC"/*/; do
  name="$(basename "$skill")"
  target="$DEST/$name"
  if [ -e "$target" ]; then
    echo "skip:   $name (already exists in $DEST)"
    continue
  fi
  ln -s "${skill%/}" "$target"
  echo "linked: $name"
done

echo
echo "Done. Next: run /setup inside a repo to configure its issue tracker and labels."
