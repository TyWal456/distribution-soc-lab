# Present the project honestly

This is an AI-assisted project scaffold. Run it, read the code, explain the SQL,
and make a substantive improvement yourself before presenting it as a skill
demonstration. Clearly label simulated data and separate implementation from
deployment. Do not imply this was work for ABARTA or a production incident.

## Five-minute demonstration

1. Explain the dispatch-workstation scenario and why operational context matters.
2. Run the local analysis and show the 9-event, 6-candidate result.
3. Explain SOC-003's same-host/user join and inclusive 600-second window.
4. Show why maintenance stays visible but gets approved_change disposition.
5. Explain the blocked attempt, evidence gaps, and operational coordination.
6. Show a test you understand, an improvement you made, and its actual result.

If deployed, show the actual Athena query results and execution IDs as a
separate demonstration. Record AWS costs and cleanup in your own notes.

## Resume language after personally running and understanding the local version

Distribution SOC Investigation Lab | Python, SQL, Security Analysis

- Validated three SQL detection rules against synthetic endpoint and firewall
  logs, correlating suspicious process activity with restricted-network attempts.
- Documented an incident timeline, scoped maintenance exceptions, and response
  recommendations accounting for distribution-system availability.

## Additional bullet only after successful AWS deployment and query validation

- Deployed an S3, Glue Data Catalog, and Athena lab; executed detection queries
  and verified results against a local test dataset.

Replace generic wording with your own measured work. Do not claim production
experience, attack prevention, percentage improvements, Sentinel/KQL experience,
or time savings without supporting evidence. SQL/Athena is distinct from KQL.

## Suggested personal extension

Add a fourth scenario in a separate data folder: approved maintenance runs
outside its change window. Predict which findings return to investigate,
execute it, and document the observed result. Then add one narrowly scoped
rule improvement and test both malicious-looking and benign examples.

## Publishing

Create a separate GitHub repository named `distribution-soc-lab`. Upload the
project contents so README.md and lab.py are at its root. Keep the existing
login lab as a separate project. Include your own AWS evidence only if actually
executed. Review screenshots and files for secrets before publishing. No
repository was created or pushed by the builder.
