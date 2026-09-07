# Official implementation references

Consulted 7 September 2026. Cloud configuration should be rechecked before
deployment because services and permissions can change.

- Hive JSON SerDe; the template uses this library for newline-delimited JSON:
  https://docs.aws.amazon.com/athena/latest/ug/hive-json-serde.html
- JSON libraries and one-record-per-line requirements:
  https://docs.aws.amazon.com/athena/latest/ug/json-serde.html
- Athena workgroup CloudFormation resource:
  https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-athena-workgroup.html
- Workgroup configuration and enforcement:
  https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-properties-athena-workgroup-workgroupconfiguration.html
- Per-query scan cutoff API requirements:
  https://docs.aws.amazon.com/athena/latest/APIReference/API_WorkGroupConfiguration.html
- Glue external table CloudFormation resource:
  https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-glue-table.html
- Glue storage descriptor and schema:
  https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-properties-glue-table-storagedescriptor.html

These references inform the supplied infrastructure and format choices. They
are not evidence that this project has been deployed or queried in AWS.
