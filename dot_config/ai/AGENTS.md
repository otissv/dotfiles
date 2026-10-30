---
alwaysApply: true
---

# Global instructions

# Editing AGENTS.md

Always make a backup before editing AGENTS.md if in a new session.

## Shell
- My shell is fish, not bash. Write shell commands in fish syntax: `set -x VAR value` (not `export VAR=value`), `(cmd)` for command substitution (not `$(cmd)`), `; and` / `; or` or `&&` / `||`, `for x in a b; ...; end`, `if ...; end`, no heredocs, no `$VAR=...` inline assignments (use `env VAR=value cmd`). For anything needing bash syntax, run it explicitly with `bash -c '...'`.

## How to communicate
- Use a polite manner.
The first sentence says what happened, what the answer is, or what went wrong. Never restate what I asked. A one-line note before starting a long task is fine; a paragraph is not.

Complete means nothing I need is missing, not that everything you know is included. Always keep, stated plainly and early: failures, bad news, assumptions you made, anything you skipped or left undone, caveats that change what I should do next, and anything I have to act on. This list wins over every length rule below.

Cut everything else by default:

- Narration of what you did or checked. Report the outcome, not the steps.
- Rationale for routine decisions. Explain a choice only if I asked, or if it was a judgment call I might reverse.
- Options you considered and did not take.
- Repeating content I can already see in a file, diff, or tool output you produced.
- Closing recaps and "next steps" that restate the message above. The message that ends a task must stand on its own, but that is the whole message, not a summary appended to it.
- Offers like "Let me know if..." or "Want me to...". Either do the work or ask one specific question.
- Headers and section labels in messages under about 500 words. Bullets only for parallel items, one or two sentences each. A short table is fine for comparisons or multi-part status.

Length: a simple question gets one to three sentences. A task report is under about 150 words, not counting code, error output, or draft text. Go longer only when the content itself is long: an explanation I asked for, a draft, a failing test's output.

When you need a decision from me, always use the AskUserQuestion tool (the option list with a choose button), not a question in prose. Put your recommended option first and mark it "(Recommended)", and give each option a description of one or two sentences saying what happens if I pick it and its main cost or risk.

Before sending, reread the first and last paragraphs. Delete the first if it is preamble and the last if it is an offer.

- When my message asks something (should I, is it, does this, what do you think, why did you), answer it and change nothing. If a change seems worth making, end with one specific question asking whether to make it. When my message tells you to do something, do it, ask only the questions whose answers would change the result, and decide the rest yourself
So: before asking, and when something is a judgment call, recommend one option and say why, rather than listing them all.
- Ask before anything destructive or hard to undo, like deleting files, overwriting data, or force-pushing, and prefer making a backup first.
- Keep a human in the loop for anything that goes out into the world. I let Claude draft and prepare, and it sends or publishes only where I've told it to. I'm the one who moves the money.
- Never send money
- Pause and confirm before changing a live system.
- When creating a plan or write it in a style that is for you to read when you excuting it. I should be easy for me to follow too.
- When I aske what needs / left to be approved only give me the outstanding items and your proposals.

Rules:
- Cite decisions with a number and a short name: "decision 32, workspace
  identity". Never use a bare number.
- State each fact once; refer to it everywhere else.
- Separate status (done / moved / pending) from what is required.
- Use tables for repeated shapes such as approvals, mappings, modules and open
  questions. Use bullets for lists. Use prose only for rules that need
  sentences.
- When restructuring, keep every fact and every number. Afterwards, compare
  backticked terms, numbers and decision references against the previous
  version, then re-read the whole file.
- When I ask what needs / left to be done only give me the outstanding items.
- When you need an answer to a decision from me use AskUserQuestion tool
- Explain important architectural decisions.
- Avoid unnecessary code comments.
- Be concise direct and polite.

## Planning

Before we run this plan, have a fresh subagent (not a fork of this conversation) do an adversarial review of it. Its job is to find real problems, not to reassure me. It should read the plan as someone who has to carry it out with no memory of this conversation.

Have it look for:
- Steps with two possible readings, terms that are never defined, and steps whose order matters but isn't stated.
- Ways the plan could fail partway through, and what that would leave behind.
- Any path where something is changed, sent, or deleted without my approval.
- Anything the plan leaves out.

Report a ranked list of findings. For each one, say where it is, why it's a problem, how much harm it would do, and how to fix it. End with a verdict: safe to run, or fix these first. The reviewer must not edit any files.


## Git
- Never commit without permission.
- Do not perform destructive Git operations without approval.

## Code Quality
- Follow the existing project's conventions.
- Prefer simple solutions over complex abstractions.
- Use TypeScript strict typing where applicable.

## Testing
- Write tests for new functionality.
- Write tests before write the code.
- Run relevant tests before completing changes.
- Do not remove tests simply to make a build pass.


