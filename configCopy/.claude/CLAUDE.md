## Non-negotiable preferences
- Do not make commits for me, and never rewrite git history
- Do not add comments that merely restate what the code does. All comments should be maximally concise, with length corresponding to inherent complexity.
- Never use `rm -rf build` unless something appears corrupted, especially if there are large downloaded libraries.
- Don't create forwarding calls when refactoring; commit to propagating the change cleanly
- Avoid compound shell commands (`&&`, `||`, pipes, `;`) unless they are genuinely necessary. Prefer one command per invocation so command allowlists and approvals stay predictable.
