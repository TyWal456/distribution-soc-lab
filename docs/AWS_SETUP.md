# Run the project on AWS

**Status: deployment instructions supplied; AWS deployment and Athena execution
have not been performed or verified by the builder.** The local runner and
tests require no AWS account. Use this guide when ready for cloud validation.

## What gets created

- One private S3 bucket with public access blocked, bucket-owner enforcement,
  SSE-S3 encryption, and an HTTPS-only policy.
- One Glue database and three external JSON tables: events, assets, changes.
- One Athena engine v3 workgroup with enforced encrypted result storage and a
  10 MiB per-query scan cutoff. This cutoff is not a dollar budget or a guarantee
  that a cancelled query has no charge.
- All bucket objects expire after 14 days. Keep the original files and evidence
  locally. The bucket is retained on stack deletion to avoid surprise data loss.

No IAM users/access keys, VMs, agents, notifications, or automated containment
are created. Synthetic files are loaded as custom normalized logs. They are
not native CloudTrail, Defender, or Fortinet records.

## Requirements

An AWS account, a browser, and permissions to create/manage CloudFormation,
S3, Glue catalog resources, and Athena workgroups and queries. Use an approved
role or IAM Identity Center session rather than root or embedded credentials.
Organization policies and Lake Formation permissions can affect access; an
administrator may need to grant catalog permissions in a governed account.
Keep S3, Glue, and Athena in the same selected region. AWS CLI v2 is optional.

AWS usage is billable. Review current Athena/S3/Glue pricing and set a billing
alert before deployment. AWS Budgets alerts do not automatically stop spending.
Use only these tiny sample files and remove lab resources after validation.

## 1. Validate locally first

From the project folder:

```sh
python lab.py
python -m unittest discover -s tests -v
```

Use python3 if needed. Expect 9 events, 6 candidates, 3 investigate findings,
and 3 approved candidates. Do not upload files that fail validation.

## 2. Create the stack

In the AWS CloudFormation console, select your region and create a stack with
new resources using an uploaded template. Upload `infra/cloudformation.json`.
Use stack name `distribution-soc-lab`. Leave DatabaseName as
`distribution_soc_lab` unless that name is already used in the region; choose
a unique lowercase name if necessary. Review resources and create the stack.

Wait for CREATE_COMPLETE, then record these Outputs:

| Output | Used for |
|---|---|
| BucketName | Upload files and find query results |
| DatabaseName | Select the Athena database |
| WorkGroupName | Select the Athena workgroup |

Optional CLI alternative (authenticated session and configured region required):

```sh
aws cloudformation validate-template --template-body file://infra/cloudformation.json
aws cloudformation deploy --template-file infra/cloudformation.json --stack-name distribution-soc-lab
aws cloudformation describe-stacks --stack-name distribution-soc-lab --query "Stacks[0].Outputs"
```

Template validation alone does not prove resource creation or query success.
No CAPABILITY_NAMED_IAM flag is needed because this template creates no roles.

## 3. Upload the three files

In the bucket named by BucketName, create the following exact prefixes and
upload only the corresponding file to each:

| Local file | S3 object key |
|---|---|
| data/events.jsonl | data/events/events.jsonl |
| data/assets.jsonl | data/assets/assets.jsonl |
| data/changes.jsonl | data/changes/changes.jsonl |

Do not upload the ZIP, documentation, reports, backups, or duplicate data under
these prefixes. Athena scans every data file under each table location. Uploading
again should replace the same object key rather than create a second filename.

Optional CLI: replace `YOUR_LAB_BUCKET` with the exact stack output before running.

```sh
aws s3 cp data/events.jsonl s3://YOUR_LAB_BUCKET/data/events/events.jsonl
aws s3 cp data/assets.jsonl s3://YOUR_LAB_BUCKET/data/assets/assets.jsonl
aws s3 cp data/changes.jsonl s3://YOUR_LAB_BUCKET/data/changes/changes.jsonl
```

## 4. Query in Athena

Open Athena's query editor in the same region. Select the stack's WorkGroupName,
data source `AwsDataCatalog`, and the database from DatabaseName. The workgroup
already sets its result location and encryption; use this workgroup, not primary.

First run the entire contents of `queries/validation.sql`:

| table_name | row_count |
|---|---:|
| events | 9 |
| assets | 3 |
| changes | 3 |

If counts differ, correct missing/duplicate uploads and database selection before
continuing. Then run the entire contents of `queries/detections.sql` as one query.

Expected results, in timestamp order:

| rule_id | event_id | related_event_id | disposition | change_id |
|---|---|---|---|---|
| SOC-001 | S01 | empty | investigate | empty |
| SOC-002 | S02 | empty | investigate | empty |
| SOC-003 | S03 | S01 | investigate | empty |
| SOC-001 | M01 | empty | approved_change | CHG-100-1 |
| SOC-002 | M02 | empty | approved_change | CHG-100-2 |
| SOC-003 | M03 | M01 | approved_change | CHG-100-3 |

Optional CLI (replace database/workgroup values if changed):

```sh
aws athena start-query-execution --work-group distribution-soc-lab-queries --query-execution-context Database=distribution_soc_lab,Catalog=AwsDataCatalog --query-string file://queries/validation.sql
```

The response is a QueryExecutionId, not proof of success. Substitute it below:

```sh
aws athena get-query-execution --query-execution-id YOUR_QUERY_ID
aws athena get-query-results --query-execution-id YOUR_QUERY_ID
```

Wait for Status.State to be SUCCEEDED before retrieving results. Repeat with
`file://queries/detections.sql`, retaining that query's own execution ID. Results
are also stored under `athena-results/` in the lab bucket.

## 5. Record cloud evidence

Create your own `reports/AWS_VALIDATION.md` containing:

- Date, region, workgroup, engine version, and project commit if published.
- Both execution IDs and successful status (sanitize screenshots if public).
- Actual source counts and the six expected findings above.
- Bytes scanned and execution duration from the query details.
- Differences from local results, errors encountered, and how you fixed them.
- Screenshots of the query and results; no credentials or sensitive identifiers.

Only after successful execution should you claim that you deployed and tested
the project on AWS. Local SQLite tests do not validate IAM, Glue SerDe loading,
Athena execution, billing settings, or CloudFormation resource creation.

## Troubleshooting

- **Access denied:** inspect the specific denied action and resource with your
  administrator. Do not make the bucket public to resolve an IAM error.
- **No tables:** check region, database, workgroup, and stack completion.
- **Zero or extra rows:** check exact S3 prefixes, files, and duplicate objects.
- **JSON/type errors:** run local validation, regenerate only if you want the
  original fixtures, and upload one JSON object per line without pretty printing.
- **Query cancelled at scan cutoff:** check for unintended files. The supplied
  dataset is tiny; investigate before increasing the limit.
- **Database already exists:** use a unique DatabaseName for this stack.

## 6. Clean up after saving evidence

First record BucketName because the stack output disappears when the stack is
deleted. Download any results you want to keep. Delete only this lab's
CloudFormation stack. It removes the catalog and workgroup; the retained S3
bucket must be emptied and deleted separately using the S3 console. Verify its
name before emptying it, as emptying permanently removes its objects.

If you created a budget solely for the lab, remove it separately when no longer
needed. Verify no lab resources remain and review billing. Do not delete shared
organization resources. The 14-day object expiration is a fallback, not a
substitute for cleanup.
