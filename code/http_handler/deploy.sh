#!/bin/bash -e

default_region="us-east-1"
read -p "Select a region [default=$default_region] " region
: ${region:=$default_region}
echo "Region: $region"

default_env="dev2"
read -p "Select an environment [default=$default_env] " env
: ${env:=$default_env}
echo "Environment: $env"

export VERSION=$(cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c15 | sed 's/$/\n/')
export AWS_DEFAULT_REGION=$region
export ENV=$env

# Select correct AWS_PROFILE
if [ "$env" = "prod" ]; then
  export AWS_PROFILE=
else
  export AWS_PROFILE=
fi

# build image
docker-compose -f deploy.yml build

# login to ECR
version=$(aws --version | awk -F/ '{print $2}' | awk -F. '{print $1}')
if [ $version -eq "1" ]; then
  login=$(aws ecr get-login --no-include-email) && eval "$login"
fi
if [ $version -eq "2" ]; then
  aws ecr get-login-password | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
fi

# push image to ECR repo
docker-compose -f deploy.yml push

# deploy image
if [ "$region" = "us-west-2" ]; then
  fargate service deploy -i ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${APP_NAME}:0.0.0-local.${VERSION} --cluster ${APP_NAME}-${ENV}uswest2 --service ${APP_NAME}-${ENV}uswest2  --wait-for-service
else
  fargate service deploy -i ${AWS_ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${APP_NAME}:0.0.0-local.${VERSION} --cluster ${APP_NAME}-${ENV}useast1 --service ${APP_NAME}-${ENV}useast1  --wait-for-service
fi
