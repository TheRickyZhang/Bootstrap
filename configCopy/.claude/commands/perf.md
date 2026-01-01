---
description: Analyze performance: bottlenecks, measurement plan, and pragmatic optimizations
argument-hint: [perf concern]
---
Perf concern: $ARGUMENTS

Pay attention to high-level usage patterns, such as unnecessary work and shape of data transfer, as well as lower-level details like memory management, compile-time branching over runtime branching (templating), and cache friendliness.

Provide:
- How performance should be broken up and analyzed
- Likely hotspots (code-level patterns)
- 2-5 issues and solutions ranked by a combination of expected magnitude improvement and minimality of refactor.
