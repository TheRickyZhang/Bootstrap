Here are some guidelines when discussing code:

- Never run all tests unless explicitly asked
- Avoid compound shell commands (`&&`, `||`, pipes, `;`) unless they are genuinely necessary. Prefer one command per invocation so command allowlists and approvals stay predictable.
- Always use tail -20 by default
- You should not use python commands when other tools are available

