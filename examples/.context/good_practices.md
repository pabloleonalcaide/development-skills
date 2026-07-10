# Good practices (review checklist)

> Template. The fresh-eyes review in `develop`'s hardening (Standards axis) applies this list.

- [ ] Value objects over primitives for domain concepts.
- [ ] Dependencies point inward; no domain → infrastructure imports.
- [ ] Ports declared by the application, implemented by adapters.
- [ ] Tests assert behavior, at the right level, and actually fail without the code.
- [ ] No defensive guards bolted on without a root cause.
- [ ] Names match the `glossary.md` vocabulary.
- [ ] No scope creep beyond the blueprint.
- [ ] (add your repo's recurring smells here)
