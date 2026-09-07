# Investigation: restricted-network attempt from a dispatch workstation

**Case:** LAB-001 · **Date:** 7 September 2026 · **Status:** Needs investigation

This is an analysis of the supplied fictional scenario, not a real incident.
The three detections below are related findings within one sample case.

## Manager briefing

A dispatch workstation recorded an encoded PowerShell command, an allowed
8 MB outbound transfer, and a blocked attempt to connect to a restricted
operational network within four minutes. The combination warrants prompt
investigation because the workstation supports dispatch. The records do not
establish malware, data theft, or access to the restricted destination.
Coordinate any containment decision with Distribution Operations and the
incident lead; preserve evidence and identify a dispatch fallback first.

## Evidence timeline (UTC)

| Time | Event | Observation | Interpretation |
|---|---|---|---|
| 09:00:00 | S01 / SOC-001 | alice starts PowerShell with -EncodedCommand on warehouse-pc-01 | Flag warrants review; encoded commands also have legitimate uses |
| 09:02:00 | S02 / SOC-002 | Allowed 8,000,000-byte transfer to 203.0.113.50:443 | Transfer exceeds lab threshold; content and destination ownership unknown |
| 09:04:00 | S03 / SOC-003 | Blocked connection to 192.0.2.80:445 in restricted_ot zone | Attempt is recorded; successful access is not demonstrated |

The same host and user occur in all three events. S03 is 240 seconds after S01,
within the 600-second correlation window. No matching approval exists. The
asset record identifies Distribution Operations as owner and high criticality.

## Competing explanations

1. Unauthorized execution followed by outbound activity and attempted movement.
2. Legitimate support activity with missing or incorrect approval records.
3. Unrelated activity under the same user/host that happens to overlap in time.

The sample's encoded command represents harmless `Write-Output 'lab'` text.
That illustrates why a command-line flag alone is not proof of malicious intent.
The transfer and restricted-network attempt still need independent explanation.

## Evidence to request

- Confirm user activity and change records with the user and operations owner.
- Obtain process ancestry, script content, executable hash/signature, and any
  available endpoint findings; link process GUIDs to network events if possible.
- Check DNS/proxy/firewall records, session outcomes, and destination ownership.
- Review identity and remote access logs around the incident window.
- Determine whether S02 involved sensitive files; byte count alone is insufficient.
- Check destination-side logs for activity beyond the blocked S03 event.

## Recommended disposition

Escalate as a suspicious sequence requiring investigation, not confirmed
compromise. Preserve available logs. If additional evidence supports active
compromise, coordinate narrowly scoped containment with the incident lead and
Distribution Operations; consider an operational fallback before host isolation.
Do not infer that the firewall block resolved all potential risk.

## Control comparison

The maintenance workstation produces three similar rule candidates at
10:00–10:04 UTC. Each matches a bounded approval scope, including both sides of
the correlated finding. Keep these visible and verify ticket context before
closure. The office scenario at 11:00–11:02 produces no candidates; this means
only that these three rules did not match.

## Closure criteria

Document an evidence-supported explanation, the scope of affected systems,
actions actually taken, owner confirmation, and follow-up monitoring. Record
unresolved uncertainty. The supplied case remains open pending these checks.
