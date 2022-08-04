# doppler_common

## The child module of all doppler modules

### Contains terraform files for resources that don’t have any source / destination challenges(as in S3 replicates from the source to the destination)

appautoscaling.tf - creates min / max number of containers to run and the cpu percentages to scale up and down on.
athena.tf - creates glue and athena resources to allow querying of target s3 bucket
cicd.tf - creates iam user to allow ci cd of fargate containers
ecs-event-stream.tf - creates cloudwatch event rule to stream ecs logs to cloudwatch
ecs.tf - creates fargate container using definitaion
ilb-http.tf - internal http listener
ilb.tf - internal load balancer adding logging to s3 and target groups
kinesis.tf - creates kinesis data stream and firehose
lb-http.tf - creates http listener
lb-https.tf - creates https listener. contains logic to create ACM certs with DNS verification using route 53lb.tf - creates load balancer adding logging to s3 and target groups
lb.tf - load balancer adding logging to s3 and target groups
lblogs-athena.tf - creates glue and athena resources to allow querying of load balancer logs
main.tf - main entrypoint into module
nsg.tf - creates security group rules to allow communication from the load balancer to the target groups to the containers
role.tf - creates role to allow container to communicate with kinesis, sqs, cloudwatch, ssm, and kms
sqs.tf - creates dead letter queue for failed kpl messages to reside in.
variables.tf - variables needed by this module.
versions.tf - controls versioning of terraform resources
