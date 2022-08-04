# doppler_destination

## Parent module of children module doppler_common
### Contains terraform files for the S3 destination. This is currently us-east-1. The destination verbiage is used to represent the final location of the data. It will flow into the S3 bucket here from another region(source) via cross region replication where it is then loaded into a snowflake database.

main.tf - main entrypoint into module
s3.tf - creates a basic s3 bucket with KMS encryption and versioning turned on.
variables.tf - variables needed by this module.
versions.tf - controls versioning of terraform resources
