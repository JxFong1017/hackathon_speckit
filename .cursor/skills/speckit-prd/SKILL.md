---
name: "speckit-prd"
description: "Draft and refine a PRD by asking up to 5 targeted product questions, then mark it Ready for /speckit-specify. When Glean, Confluence, Backstage, GitHub, or the RFC skill is available, ground the draft in those sources. Use when the user runs /speckit-prd or wants to shape a PRD before a feature spec."
compatibility: "Requires spec-kit project structure with .specify/ directory"
metadata:
  author: "speckit-template"
  source: ".specify/templates/prd-template.md"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Write or update one product requirements document under `docs/prd/`. Ask only the product questions that would change that document. Do not create a feature branch, a `specs/` directory, or `spec.md`.

This command runs before `/speckit-specify`. Stack, libraries, and file layout belong in `/speckit-plan`. Behaviour, data, and acceptance details belong in `/speckit-clarify` after a spec exists.

1. **Resolve the file**
   - Ignore files whose names end in `-validation.md` or `-design-prompt.md`.
   - If `$ARGUMENTS` includes a path to an existing `docs/prd/*.md` PRD, update that file.
   - Otherwise derive a 2–4 word kebab-case name from the idea (action-noun when possible, keep acronyms). Target path: `docs/prd/<name>.md`.
   - If that path does not exist, search `docs/prd/*.md`, still ignoring validation and design-prompt files. When exactly one file is clearly the same product as the new message, update it. When several could match and the message names none, ask which path to update. That question does not count toward the five-question cap.
   - When no file matches, create one. `mkdir -p docs/prd` and copy `.specify/templates/prd-template.md`.

2. **Load context**
   - **IF EXISTS**: read `.specify/memory/constitution.md` per **Project memory paths** in `.cursor/rules/specify-rules.md`. Use it to prefer options that fit the project principles.
   - Read the target PRD when it already exists.

3. **Connected company context**

   Run this before the draft. Use only servers and skills that are actually available in this session. Skip a missing one and list it in the completion report. Do not start an auth flow. Do not invent a document, owner, system, or RFC.

   Cap the lookup: one search per connected source, then open at most two results that clearly match the idea. This lookup does not count toward the five product questions.

   | Source            | When it is available                                                            | What to do                                                                                                                                                                                   |
   | ----------------- | ------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
   | Glean             | Glean tools are in the session                                                  | `search` for documents about the product or system named in `$ARGUMENTS`. Cite title, URL, and last updated date. Use `employee_search` only when the open question is who owns that system. |
   | Confluence / Jira | Atlassian tools are in the session                                              | `search` with a natural-language query. Open a page with `getConfluencePage` only when that search returned it.                                                                              |
   | Backstage         | Backstage tools are in the session                                              | `backstage-search` when the idea names a system or service. Record the owning component in Already decided.                                                                                  |
   | GitHub            | GitHub tools are in the session                                                 | Look up a repo only when the user named one, or a result above linked one.                                                                                                                   |
   | RFC skill         | The `rfc` skill is installed, or Backstage `list-rfcs` / `get-rfc` is available | Follow the **RFC skill** section below.                                                                                                                                                      |

   Write each retrieved item under `## Sources` as `- [Title](url) — what it changed`. A search with no match stays an Open question. It is not evidence that the thing does not exist.

   Fold matching facts into Already decided or Assumptions. When two sources disagree, keep both in Open questions and ask about that conflict later.

4. **Draft first**

   Fill every section you can from `$ARGUMENTS`, the existing PRD, the constitution, and the sources retrieved above. Write the file before asking a question. Show the draft in chat, then ask.

   Leave a section as a one-line gap only when the message does not answer it. Do not invent an audience, an outcome, or an out-of-scope list.

5. **Choose questions**

   Build an internal queue of at most 5. Do not print the queue. Skip a topic the draft already answers in concrete language.

   Ask only from this list, in this order:

   | Topic           | What a useful answer decides                                                                                                                                  |
   | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
   | Who it is for   | One audience for this version. Other audiences belong in Out of scope.                                                                                        |
   | Problem         | What they cannot do today, in one sentence.                                                                                                                   |
   | Outcome         | What they can do when this version works, as something a person can try.                                                                                      |
   | Out of scope    | What this version will not include.                                                                                                                           |
   | Already decided | A platform, dataset, system, or deadline already chosen. Ask only when that choice changes the product. A connected source can supply the recommended option. |

   Do not ask about frameworks, libraries, file layout, data models, or acceptance-test detail.

6. **Ask one question at a time**
   - Present exactly one question.
   - Prefer a multiple-choice question with 2–5 mutually exclusive options. Mark one **Recommended** and give a one-sentence reason tied to the draft or constitution. Then a markdown table of the options, plus a `Short` row when a free-form answer is reasonable.
   - After the table: `You can reply with the option letter (e.g., "A"), accept the recommendation by saying "yes" or "recommended", or provide your own short answer.`
   - When no real options exist, give a **Suggested** answer of five words or fewer and a one-sentence reason. Then: `Format: Short answer (<=5 words). You can accept the suggestion by saying "yes" or "suggested", or provide your own answer.`
   - "yes", "recommended", or "suggested" accepts the recommendation you just gave.
   - If the reply is ambiguous, ask once more about the same question. That retry does not count as a new question.
   - Stop when the user says "done", "stop", or "proceed", when five questions have been answered, or when Problem, Who it is for, Outcome, and Out of scope are all concrete.

7. **Update the file after each answer**
   - Set **Updated** to today's date.
   - Under `## Decisions`, ensure `### Session YYYY-MM-DD` exists for today and append `- Q: <question> → A: <answer>`.
   - Write the answer into the matching section. Replace contradictory text. Do not leave both versions.
   - Move a displaced audience or behaviour into Out of scope when the answer excludes it.
   - Save the file before the next question.

8. **Set status**

   Leave **Status** as `Draft` when Problem, Who it is for, Outcome, or Out of scope is still empty.

   When those four sections contain concrete text, keep **Status** as `Draft` so `/speckit-validate` can suggest refinements. Set **Status** to `Ready` only when the user says "ready", "mark ready", or "skip validation" and those four sections are filled.

   Unanswered topics go under Open questions. Do not fill them with a guess. Assumptions hold defaults the user did not contradict.

9. **Report**
   - Path of the PRD
   - Status (`Draft` or `Ready`)
   - Sources used, and which connected-context sources were skipped because they were not available
   - Questions answered (count)
   - Sections still open, if any
   - When the four blocking sections are filled and status is Draft, the optional next command is `/speckit-validate`. The user can instead say "mark ready".
   - When status is Ready, the next command is `/speckit-specify` with that PRD path. If this version has a UI, also offer `/speckit-design-prompt` for a Riz mock-up prompt.
   - When a blocking section is empty, name it.

## RFC skill

When the idea touches auth, secrets, logging, monitoring, personal data, privacy, CI, localisation, or a named RFC, read and follow the installed `rfc` skill before drafting.

- Prefer an **ADOPTED** RFC. When you cite a **DRAFT**, record that status. When you cite a **DEPRECATED** RFC, say it may be outdated and do not treat it as a constraint.
- Cite the RFC number in Already decided or Assumptions, for example `Per RFC008 (Application Authentication), …`, and add the same line under Sources.
- Fetch only the RFCs that apply. Use Backstage `list-rfcs` and `get-rfc` when those tools are connected. When they are not, follow the `rfc` skill's GitHub fallback.
- When neither the `rfc` skill nor those Backstage tools are available, add an Open question naming the topic. Do not invent RFC text.
