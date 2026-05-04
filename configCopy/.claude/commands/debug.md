---
description: Debug systematically: repro, hypotheses, instrumentation, fix strategy
argument-hint: [bug symptom]
---
Bug: $ARGUMENTS

Output:
1) Minimal steps I should try to produce or mock in organized environment
2) one hypothesis if you are confident of the root cause, otherwise multiple hypotheses ranked by likelihood
3) What logs/asserts/tests to add to confirm and ensure correctness in the future.
4) Minimal fix approach. In addition, if there is a cleaner way to address by refactoring, mention it.
