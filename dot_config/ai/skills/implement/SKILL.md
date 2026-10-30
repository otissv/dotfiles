---
name: implement
description: Production implementation bar. Use when implementing or finishing a feature, phase, or fix that is meant for production, or when the user asks for a full, production-ready implementation with no gaps.
---

# Production implementation

- Fully implement for production, without backwards compatibility, legacy or temporary code.
- Ensure defense-in-depth and all manual memory is cleaned up with appropriate allocators, including tests.
- Write neccesay BBD, TTD tests first before starting implmentation. Then read the test to see the make sense.
- Exit criteria:
  - You can clearly and confidently say there are no gaps in the implementation.
  - All test pass
