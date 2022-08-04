# Doppler

### code

- The source code for the receive endpoint.

### iac

- The infrastructure as code to create the resources for receive.

## Setup

This project assumes some prerequisites: provisioning of public and private VPCs/subnets is left to you,
and a registered domain name is required for exposing Doppler to the internet.

1. **Placeholders**

* The Doppler IAC (Infrastructure as Code) has been templated with the following placeholders:
  * `AWS_ACCOUNT`
  * `APP_NAME`
  * `DOMAIN_NAME`

* These values must be populated before proceeding. One method for doing so may be to simply recursively search and replace the doppler repo for these placeholders (e.g. `s/${AWS_ACCOUNT}/123456789/g`).

2. **Base Terraform**

- Navigate to `iac/base/`
- Populate `terraform.tfvars` with your application's config.
- Run `terraform init` and `terraform apply`
- Make note of the name of the generate S3 bucket.

3. **Create Doppler Environment(s)**

- Navigate to `iac/env/prod/`
- Populate `terraform.tfvars` with your application's config. The ARNs of your VPCs, private and public subnets, and your root domain name are needed at this stage.
- Run `terraform init` and `terraform apply`. This will provision an east and west region for the prod environment of Doppler.
- Make note of the ARNs for the us-east and us-west load balancers.
- Copy/paste the `prod/` directory and repeat the above steps for additional environments (e.g. dev, test, etc.) as desired.

4. **Global Base**

- Navigate to `iac/global/base/`
- Populate `terraform.tfvars` with your application's config.
- Run `terraform init` and `terraform apply`
- Make note of the name of the generate S3 bucket.

5. **Global Environment(s)**

- Navigate to `iac/global/env/prod/`
- Populate `terraform.tfvars` with your application's config.
- Enter the load balancer ARNs you noted in step (3).
- Run `terraform init` and `terraform apply`
- Copy/paste the `prod/` directory and repeat the above steps for additional environments (e.g. dev, test, etc.) as desired.

6. **Cross Region Replication (CRR)**

- Navigate to `iac/crr/env/prod/`
- Ensure `create_crr_west_to_east.sh` is properly configured with your application's values.
- Run `create_crr_west_to_east.sh` to setup S3 cross region replication.
- Adjust the values in the script and rerun for any additional environments as desired.

## License

This repository is released under [the MIT license](https://en.wikipedia.org/wiki/MIT_License).  View the [local license file](./LICENSE).
