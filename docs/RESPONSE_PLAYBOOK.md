# Analyst response playbook

This document recommends actions. The program takes no containment action.

1. **Validate the data.** Confirm source counts, event IDs, UTC timestamps, query
   version, and whether execution was local or Athena. Check for stale reports.
2. **Triage the finding.** Read the underlying process and network records,
   identify owner and business function, and distinguish blocked from allowed.
3. **Check authorization.** Independently verify approval scopes and their time
   windows. A change ticket title alone does not authorize all activity.
4. **Build the timeline.** Correlate endpoint, identity, and firewall evidence.
   Record alternative explanations and missing evidence. Time proximity is not
   process attribution.
5. **Coordinate response.** Notify the incident lead through the organization's
   established process. For operational systems, involve their owner and ask
   about dispatch continuity, maintenance constraints, and safe isolation options.
6. **Contain only with context.** If evidence justifies it, propose account,
   destination, session, or host controls within authorized procedures. Record
   approver, rationale, impact, and rollback. Do not automatically isolate OT.
7. **Recover and validate.** Verify the root issue is addressed, confirm system
   function with the owner, rerun detections, and monitor for recurrence.
8. **Close and improve.** Record evidence, actions, remaining risks, and lessons.
   Tune rules against benign examples and retain regression tests.

## Handoff record

- Case / analyst / date:
- Execution environment and query ID:
- Event IDs and affected host/user:
- Observed behavior and confidence:
- Asset owner / business impact:
- Approval records checked:
- Evidence missing / next checks:
- Proposed response / approver / rollback:
- Actions actually taken:
- Follow-up owner / closure criteria:
