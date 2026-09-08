DISTRIBUTION SOC LAB - AWS / ATHENA EDITION
Independent educational project. All data is fictional. No affiliation with
ABARTA Coca-Cola, Coca-Cola, or any employer. 

On macOS/Linux use python3 if python is unavailable.
Requires Python 3.10 or later. No pip packages, virtual machines, or paid
software are required for the local version. Nothing contacts AWS locally.

EXPECTED RESULT
Reviewed 9 events: 6 candidates, 3 alerts, 3 approved candidates.

Scenario A: warehouse-pc-01 / alice
  SOC-001: encoded PowerShell command (S01).
  SOC-002: allowed 8,000,000-byte external transfer (S02).
  SOC-003: blocked restricted-network attempt after PowerShell (S03).
Scenario B: maintenance-pc-01 / maint_admin
  Same three candidate rules; exact, time-bounded changes explain the events.
  Candidates remain visible with approved_change disposition.
Scenario C: office-pc-01 / bob
  Ordinary process and network activity; no matching candidates.
There are three rule findings for the suspicious scenario, not three confirmed
incidents. No malware is run. The encoded string represents harmless text output.

WHAT YOU GET
lab.py                    Validates data, executes SQL locally, exports reports.
generate_data.py          Recreates deterministic fictional sample data.
data/events.jsonl         Normalized endpoint and firewall events.
data/assets.jsonl         Owners, business functions, and criticality.
data/changes.jsonl        Exact maintenance approval scopes.
queries/detections.sql    Three detections, correlation, and approval enrichment.
queries/validation.sql    Counts source records before interpreting findings.
infra/cloudformation.json AWS S3 bucket, Glue tables/database, Athena workgroup.
docs/AWS_SETUP.md         Deployment, upload, query, validation, cleanup steps.
docs/DETECTION_GUIDE.md   Rule logic, schema, assumptions, and limitations.
docs/INCIDENT_REPORT.md   Evidence-based investigation of the sample incident.
docs/RESPONSE_PLAYBOOK.md Analyst response and operational coordination.
docs/PORTFOLIO.md         Demo outline and honest resume language.
docs/SOURCES.md           Official AWS references used for this project.
tests/test_lab.py         Behavioral and validation tests.
reports/TEST_RESULTS.txt  Actual local test output and verification scope.
reports/report.html      Generated self-contained visual report.
reports/results.json     Full detection evidence and execution status.
reports/detections.csv   All candidates, including approvals, for review.

REPRODUCE AND EXPERIMENT
python generate_data.py
python lab.py
python -m unittest discover -s tests -v

generate_data.py replaces the three bundled data files with the original sample.
To preserve experiments, copy data to a separate folder and run:
python lab.py --data my_data --output reports/my_experiment

Default paths are relative to lab.py. Explicit relative paths are relative to
your terminal's current folder. Successful runs replace report files in the
chosen output folder. Invalid input stops before report generation; prior
reports remain and should not be mistaken for results from the failed run.
An output write error can leave partial files; only trust a successful run.

AWS VERSION
Read docs/AWS_SETUP.md after the local run passes. AWS is optional and incurs
usage charges. The project supplies infrastructure and SQL; it has not been
deployed or executed in Athena by the builder. Local SQL execution is evidence
of local behavior, not proof of AWS deployment or identical engine behavior.
Use the included AWS validation checklist and record actual query execution IDs.

This first version is batch analysis with S3 and Athena. It does not deploy
CloudTrail, live endpoint agents, scheduled rules, Lambda, or notifications.
Synthetic endpoint/firewall records are not native AWS CloudTrail records.

VERIFICATION
See reports/TEST_RESULTS.txt for the actual local test transcript.
Linux / Python 3.12.13 was tested. Windows and macOS were not separately tested.

LICENSE
MIT; see LICENSE. No credentials or real organization logs belong in this repo.
