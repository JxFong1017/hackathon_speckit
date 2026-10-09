---
name: "speckit-design-prompt"
description: "Write a copy-paste prompt for the Glean agent Riz (UI/UX Mock-up Partner) from a Ready PRD. Use when the user runs /speckit-design-prompt or wants a mock-up prompt for https://app.glean.com/chat/agents/22117631045e431c8009940e14719ff8."
compatibility: "Requires spec-kit project structure with .specify/ directory"
metadata:
  author: "speckit-template"
  source: ".cursor/skills/speckit-design-prompt/SKILL.md"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Produce one first message for **Riz – UI/UX Mock-up Partner**.

Agent: https://app.glean.com/chat/agents/22117631045e431c8009940e14719ff8

Riz is a chat agent. It designs mock-ups from the first message. If fidelity, SEEK Braid, the user, the goal, or the primary journey are missing, it stops to ask. This command fills those from the PRD so the pasted message can go straight to a mock-up.

Do not invent screens, copy, or a visual system. Do not call the Glean agent. The deliverable is text the user pastes.

1. **Load the PRD**
   - If `$ARGUMENTS` includes a path under `docs/prd/`, use that file.
   - Otherwise use the only `docs/prd/*.md` whose `**Status**:` is `Ready`, ignoring files whose name ends in `-design-prompt.md`.
   - If several Ready PRDs exist and none is named, ask which path to use.
   - If the chosen file is `Draft`, or none is Ready, stop and tell the user to finish `/speckit-prd`.

2. **Load a spec when one cites that PRD**

   Search `specs/*/spec.md` for a `**PRD**:` line pointing at the chosen file. When one matches, use its P1 user story, acceptance scenarios, and edge cases as the journey and states. Do not pull in behaviour the PRD lists as out of scope.

3. **Confirm design direction**

   Riz will ask these itself when they are absent. Ask here first, one at a time, only for a choice the PRD and arguments do not already state.
   - **Fidelity.** Recommended: **low** — structure, hierarchy, and flow. High fidelity adds realistic content and visual styling.
   - **SEEK Braid.** Recommended: **no**, unless Already decided or Sources say this is a SEEK product UI. Do not assume Braid.

   Use the same reply rules as `/speckit-prd`: option letter, "yes", or a short answer. Record the answers in the PRD under `## Already decided` and save it.

4. **Write the prompt file**

   Save `docs/prd/<prd-name>-design-prompt.md`. `<prd-name>` is the PRD filename without `.md`.

   The file contains the agent URL, the PRD path, today's date, and the paste block. The paste block uses this shape, with only facts from the PRD, the spec, and the two answers above:

   ```markdown
   Design a mock-up. Decisions below are settled. Ask only if a section says it is unknown.

   Fidelity: low | high
   Design system: SEEK Braid | no design system

   ## App

   [One sentence from the PRD title and Problem.]

   ## Who it is for

   [Who it is for.]

   ## Goal

   [Outcome.]

   ## Primary journey

   [Numbered steps from the P1 acceptance scenarios when a spec exists. Otherwise the Outcome, and the line "Steps beyond this outcome are unknown."]

   ## States to show

   [Empty, loading, error, and success only when the PRD or spec mentions them.]

   ## Platform and viewport

   [From Already decided, or "Unknown".]

   ## Content and data

   [From Assumptions and Already decided, or "Unknown".]

   ## Success

   [How someone can tell the journey worked.]

   ## Constraints

   [Already decided, including any ADOPTED RFC.]

   ## Out of scope

   [Out of scope list.]

   ## References

   [Sources as title plus URL. Omit this section when Sources is empty.]
   ```

5. **Report**

   Show the paste block again in chat, inside one fenced code block, so the user can copy it.

   Then give the agent URL and the path of the prompt file. Tell the user to paste the block as the first message in a new Riz chat. After Riz returns screens, save them under `specs/<feature>/references/design/` once a feature spec exists.
