#! /bin/bash
set -e

# push image to ECR repo
export AWS_PROFILE=
export AWS_DEFAULT_REGION=us-west-2

aws s3api delete-bucket-replication \
    --bucket doppler-${APP_NAME}-produswest2
