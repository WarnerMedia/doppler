# doppler_source

## Parent module of children module doppler_common

### Contains terraform files for the S3 source. This is currently us-west-2 but it could be expanded to as many regions as desired. The source verbiage is used to represent the temporary location of the data. It will flow from the S3 bucket in this region(source) to the destination s3 bucket via cross region replication where it is then loaded into a snowflake database.

main.tf - main entrypoint into module
s3.tf - creates a basic s3 bucket with KMS encryption and versioning turned on as well as the logic to replicate the data in the bucket back to the destination.
variables.tf - variables needed by this module.
versions.tf - controls versioning of terraform resources
