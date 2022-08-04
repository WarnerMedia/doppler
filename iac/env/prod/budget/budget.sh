#! /bin/bash
set -e

# push image to ECR repo
export AWS_PROFILE=
export AWS_DEFAULT_REGION=us-east-1

# aws budgets delete-budget \
#     --account-id ${AWS_ACCOUNT} \
#     --budget-name "${APP_NAME}-prod-budget-monthly"

aws budgets create-budget \
    --account-id ${AWS_ACCOUNT} \
    --budget file://budget.json \
    --notifications-with-subscribers file://subscribers.json
