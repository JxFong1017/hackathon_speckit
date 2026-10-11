---
name: "speckit-validate"
description: "Optionally check a Draft PRD as market validation: whether the audience has the problem, whether something already serves them, and whether the idea is feasible. Suggest edits only from retrieved evidence. Apply a suggestion only after the user accepts it. Use when the user runs /speckit-validate or wants to test an idea before marking a PRD Ready."
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

This command is optional. It runs after `/speckit-prd` has written a PRD whose Problem, Who it is for, Outcome, and Out of scope sections contain concrete text. It answers whether the idea is feasible in the market for that audience. It recommends refinements. It does not mark the PRD Ready and does not create a spec.

This is not an engineering standards review. Do not fetch logging, authentication, CI, or other RFCs unless a retrieved source says that limit blocks the outcome, or the user named that limit. Do not suggest an edit that does not change what the audience can try.

1. **Load the PRD**

   A PRD is `docs/prd/<name>/<name>.md`. Ignore files whose names end in `-validation.md` or `-design-prompt.md`, and ignore any other markdown in the folder.
   - If `$ARGUMENTS` includes a path to an existing PRD, use that file.
   - Otherwise use the only remaining `docs/prd/<name>/<name>.md`. If several remain, ask which path to check.
   - If Problem, Who it is for, Outcome, or Out of scope is still a placeholder, stop and tell the user to finish `/speckit-prd`.
   - If `$ARGUMENTS` asks a market question, such as whether the idea has value for the audience, answer that question in the report from the checks below.

2. **Check the market**

   Use only servers and skills available in this session. Skip a missing one and name it in the report. Do not start an auth flow. Do not invent a document, system, owner, quote, or metric. A search with no match is "nothing found." It is not proof the idea is new, unwanted, or impossible.

   One search per connected source. Keep at most three results that speak to demand, an alternative, or a blocker. Open at most two of those. Drop a hit that only shares a keyword.

   | Check        | Question                                                                                            | Where to look                                                                                                                                                                                                                                                                                                                  |
   | ------------ | --------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
   | Demand       | Does this audience have the problem, and is there evidence they want the outcome?                   | Glean, Confluence, and Jira. Prefer research, interviews, surveys, and stated hirer or customer pain. Record the quote or metric, the audience, the date, and whether it matches this outcome or only a nearby problem.                                                                                                        |
   | Alternatives | Does a product, process, or workaround already deliver this outcome to this audience?               | Glean, Confluence, Jira, and Backstage. GitHub only when the PRD names a repo or a result links one. Name it only when it does the outcome. A same-word result that serves someone else, or a different job, goes under "Same words, different offer."                                                                         |
   | Blockers     | What retrieved limit makes this outcome impossible, or forces a smaller outcome, for this audience? | A Confluence or Glean page that states a market, policy, data, or platform limit, including a page about Databricks. Do not query a warehouse. This repo has no Databricks connector. An ADOPTED RFC only when that page or the user says it blocks the offer. A DRAFT is noted as a draft. A DEPRECATED RFC is not a blocker. |

   When the `rfc` skill is installed, follow it for a blocker RFC. When it is missing, use Backstage `list-rfcs` and `get-rfc` if those tools are connected. Fetch only that RFC. Do not invent RFC text.

3. **Write the report**

   Save `docs/prd/<name>/<name>-validation.md`, in the same folder as the PRD. `<name>` is the PRD folder name.

   Lead with the market answer in one or two sentences. Then set **Verdict** to one of:

   | Verdict              | When                                                                                                                                                |
   | -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
   | Feasible             | A retrieved source shows this audience has the problem, nothing retrieved already delivers the outcome, and nothing retrieved blocks it.            |
   | Feasible with limits | The idea can continue only if the PRD keeps a cited limit, or the evidence is a nearby problem rather than this outcome. Name the limit or the gap. |
   | Unproven             | Sources were searched and nothing shows this audience has the problem or wants the outcome. The user decides whether to continue.                   |
   | Already served       | A retrieved result already delivers the outcome to this audience. Name it. The user decides whether to continue.                                    |
   | Not feasible         | A retrieved limit makes the outcome impossible for this audience. Name it.                                                                          |

   Under **Suggestions**, number each recommended edit:

   ```markdown
   ### S1

   - **Section**: Open questions
   - **Suggestion**: Record that <evidence gap or limit>.
   - **Why**: <one sentence tied to the audience and the outcome>
   - **Source**: [Title](url)
   ```

   A suggestion must change the problem, the audience, the outcome, the scope, or an open question. Omit a suggestion that does not name a source URL. Omit a suggestion that only adds an engineering standard. If there are none, say so.

4. **Apply only what the user accepts**

   Show the verdict and the suggestions. Ask which to apply. The user may reply with numbers, "all", or "none".
   - On accept, write that suggestion into the named PRD section, replace contradictory text, and add the source under **Sources**.
   - Set the PRD **Status** to `Draft` after any accepted edit, including when it was Ready.
   - On "none", leave the PRD unchanged.
   - Record each decision in the validation file as `S1: accepted` or `S1: skipped`.

5. **Report**
   - Validation path and PRD path
   - Verdict
   - The market answer in one sentence
   - Suggestions accepted and skipped
   - Sources skipped because they were not connected
   - Next step: run `/speckit-validate` again, or run `/speckit-prd` and say "mark ready" when the four blocking sections are filled
