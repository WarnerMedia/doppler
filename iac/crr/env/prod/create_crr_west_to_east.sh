#! /bin/bash
set -e

# push image to ECR repo
export AWS_PROFILE=
export AWS_DEFAULT_REGION=us-west-2

aws s3api put-bucket-replication \
    --bucket doppler-${APP_NAME}-produswest2 \
    --replication-configuration file://replication_west_to_east.json
