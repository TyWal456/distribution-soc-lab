# Detection guide

The SQL is batch analysis over a small, normalized dataset. The local runner
loads three JSONL files into in-memory SQLite and executes the supplied SQL.
The AWS template describes the same columns for Athena engine v3. No local
database server or Python packages are needed.

| Rule | Exact condition | Evidence |
|---|---|---|
| SOC-001 | Process event; name is powershell.exe or pwsh.exe (case-insensitive); command contains a space, -EncodedCommand or -enc, and a following space (case-insensitive) | Process event ID |
| SOC-002 | Network event; external destination zone; action allowed; bytes_sent >= 5,000,000 | Network event ID |
| SOC-003 | Restricted_ot network event, allowed or blocked, with an SOC-001-like process on the same exact host and username 0–600 seconds earlier, inclusive | Network and process IDs |

SOC-002 is a fixed-volume review rule, not a statistical anomaly detector.
SOC-003 links events in time; it does not prove the process caused the connection.
Every matching process/network pair produces a candidate. Multiple findings
may describe one incident. No incident deduplication or severity scoring is claimed.

## Maintenance handling

Candidate findings are retained. A finding gets `approved_change` only when
host, user, event type, process name, command line, destination IP, destination
zone, destination port, action, and an inclusive time window match an approval.
SOC-003 additionally requires the preceding process to match an approval.
Overlapping scopes select the lexicographically smallest matching change ID.
Raw approval evidence remains in changes.jsonl; the displayed change ID for
SOC-003 is the network scope, while its process approval can be checked using
related_event_id. There is no wildcard approval.

Approval records represent trusted analyst enrichment, not assertions accepted
from an endpoint. In a real deployment, restrict who can modify them and verify
the ticket/owner independently. A matched scope is not proof the activity is safe.
Bytes transferred are not constrained by the approval scope; a real workflow
should verify expected volume before closing a large-transfer finding.

## Schema

Each JSON object occupies one line. No nulls or missing fields are accepted by
the local loader. Empty strings mean not applicable for optional string fields.

| File | Key fields |
|---|---|
| events.jsonl | event_id (unique), event_time (UTC ISO timestamp), event_epoch (matching integer seconds), host, username, event_type (process/network), process_name, command_line, dest_ip, dest_zone, dest_port, action, bytes_sent |
| assets.jsonl | host (unique), owner, business_function, criticality (low/medium/high) |
| changes.jsonl | change_id (unique), host, username, start_epoch, end_epoch, event_type, process_name, command_line, dest_ip, dest_zone, dest_port, action |

The destination zone is supplied by the fictional data; it is not derived from
an IP enrichment service. IPs use documentation ranges. Process command lines
are text evidence only and are never executed. event_epoch is used for query
arithmetic; event_time is for display. Unknown assets are kept with unknown
ownership/criticality, so missing inventory does not discard a finding.

## Limits to explain in an interview

- Flag matching misses other abbreviations, quoting, whitespace, and obfuscation.
- Fixed transfer thresholds miss low-volume or distributed activity and can
  flag legitimate transfers. No destination reputation or baseline is available.
- Host/user equality and synchronized timestamps are assumed. Case normalization
  is only applied to PowerShell names/flags, not identities or approval scopes.
- The sample has no process GUIDs, hashes, DNS, packet payloads, or authentication
  data, so it cannot establish causality, account compromise, or exfiltration.
- Approval windows and correlation boundaries are inclusive. Equal-second
  events correlate; their true within-second ordering is unknown.
- Local input validation rejects duplicate IDs. Athena tables do not enforce
  uniqueness: upload only validated files and run the count query first.
- The unpartitioned JSON scan is appropriate for this tiny lab; larger systems
  need partitioning, columnar storage, limited query windows, and measured cost.
- This project does not monitor real OT devices or provide production containment.
