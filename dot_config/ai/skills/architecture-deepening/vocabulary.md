# Vocabulary

Use these terms exactly, in reasoning, logs and reports. If the project's glossary has its own word for one of them, use the project's word and note the mapping once in the report.

| Term | Meaning | Do not say |
|---|---|---|
| **Module** | Anything with an interface and an implementation, at any size: a function, a class, a file, a package. | unit, component, service (as a general term) |
| **Interface** | Everything a caller must know to use the module correctly: signatures, plus invariants, ordering rules, error modes, required configuration and performance limits. | API, signature (as a synonym) |
| **Depth** | How much behaviour a caller gets per thing they must learn about the interface. Deep: a lot of behaviour behind a small interface. Shallow: the interface is about as complex as what it hides. Never measure depth as lines of implementation per line of interface. | |
| **Seam** | A place where behaviour can be changed without editing the code there. The seam is where an interface sits; what sits behind it is a separate decision. | boundary |
| **Adapter** | Something that fills an interface at a seam: a production implementation, an in-memory fake, a test double. | |
| **Locality** | What maintainers gain from depth: a change, a bug and its fix stay in one place. | |
| **Leverage** | What callers gain from depth: more behaviour for less interface to learn. | |

## The deletion test

Imagine deleting the module and inlining it into every caller.

- **Complexity disappears.** The module was a pass-through. It adds interface without hiding anything (pattern `pass-through-module`).
- **Complexity reappears in each caller.** The module hides something real. Keep it; if callers still repeat work around it, it should be deeper.
- **Complexity would gather behind one smaller interface.** Callers are doing the module's job. This is a deepening opportunity.

Write the result as one sentence per candidate. It is the candidate's `why` in the log.

## Seams and adapters

- **One adapter is a hypothetical seam; two adapters make a real one.** Do not add a seam unless two adapters exist or one is concretely needed now. Name the second adapter when you add a seam.
- Decide where a seam goes before deciding what goes behind it.
- **The interface is the test surface.** Callers and tests cross the same seam. If a test has to reach past the interface, the module is the wrong shape.
- A deep module may have internal seams that its own tests use; callers see only the one at its interface.

## Dependency categories

Classify each dependency of the deepened module; the category sets the test strategy.

| Category | Example | Test it with |
|---|---|---|
| In-process | Pure logic, in-memory data | The real thing, directly through the interface |
| Local, substitutable | Filesystem, SQLite, a local queue | A real local instance (temp dir, in-memory database) |
| Remote, owned by us | Our own HTTP service or database | An in-memory adapter at the seam. This is the second adapter that makes the seam real. |
| True external | Payment provider, third-party API | A fake adapter at the seam, plus contract tests against the provider's sandbox if the project has them |
