---
name: "speckit-validate"
description: "Optionally check a Draft PRD against connected SEEK sources for an existing solution and for constraints, then suggest edits. Apply a suggestion only after the user accepts it. Use when the user runs /speckit-validate or wants to refine a PRD before marking it Ready."
compatibility: "Requires spec-kit project structure with .specify/ directory"
metadata:
  author: "speckit-template"
  source: ".cursor/skills/speckit-validate/SKILL.md"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command is optional. It runs after `/speckit-prd` has written a PRD whose Problem, Who it is for, Outcome, and Out of scope sections contain concrete text. It recommends refinements. It does not mark the PRD Ready and does not create a spec.

1. **Load the PRD**

   Ignore files whose names end in `-validation.md` or `-design-prompt.md`.
   - If `$ARGUMENTS` includes a `docs/prd/*.md` path, use that file.
   - Otherwise use the only remaining `docs/prd/*.md`. If several remain, ask which path to check.
   - If Problem, Who it is for, Outcome, or Out of scope is still a placeholder, stop and tell the user to finish `/speckit-prd`.

2. **Check connected sources**

   Use only servers and skills available in this session. Skip a missing one and name it in the report. Do not start an auth flow. Do not invent a document, system, owner, or RFC. A search with no match is "nothing found." It is not proof the idea is new or impossible.

   Cap each check at three results that clearly match the PRD, then open at most two of them.

   **Already exists.** Search Glean, Confluence, Jira, and Backstage for a product, spec, system, or ticket that already does what this PRD describes. Look up a GitHub repo only when the PRD names one or a result links one. Record title and URL for each match.

   **Feasible in SEEK.** From the same PRD text, record constraints that would change scope:
   - An ADOPTED RFC. Read and follow the installed `rfc` skill. Prefer ADOPTED. Note a DRAFT as a draft. A DEPRECATED RFC is not a constraint.
   - When the `rfc` skill is missing, use Backstage `list-rfcs` and `get-rfc` if those tools are connected.
   - The Backstage component that would own the work, when the PRD names a system or a search found one.
   - A Confluence or Glean page that states a platform or data limit, including a page about Databricks. Do not query a warehouse. This repo has no Databricks connector.

3. **Write the report**

   Save `docs/prd/<prd-name>-validation.md`. `<prd-name>` is the PRD filename without `.md`.

   Set **Verdict** to one of:

   | Verdict                  | When                                                                                          |
   | ------------------------ | --------------------------------------------------------------------------------------------- |
   | Proceed                  | No overlapping system, and no adopted constraint that changes scope.                          |
   | Proceed with constraints | The PRD can continue if it keeps the cited RFC, owner, or platform limit.                     |
   | Overlaps                 | A retrieved result already covers the outcome. Name it. The user decides whether to continue. |

   Under **Suggestions**, number each recommended edit:

   ```markdown
   ### S1

   - **Section**: Out of scope
   - **Suggestion**: Move <audience> here.
   - **Why**: <one sentence>
   - **Source**: [Title](url)
   ```

   Omit a suggestion that does not name a source URL or an RFC number. If there are none, say so.

4. **Apply only what the user accepts**

   Show the verdict and the suggestions. Ask which to apply. The user may reply with numbers, "all", or "none".
   - On accept, write that suggestion into the named PRD section, replace contradictory text, and add the source under **Sources**.
   - Set the PRD **Status** to `Draft` after any accepted edit, including when it was Ready.
   - On "none", leave the PRD unchanged.
   - Record each decision in the validation file as `S1: accepted` or `S1: skipped`.

5. **Report**
   - Validation path and PRD path
   - Verdict
   - Suggestions accepted and skipped
   - Sources skipped because they were not connected
   - Next step: run `/speckit-validate` again, or run `/speckit-prd` and say "mark ready" when the four blocking sections are filled
