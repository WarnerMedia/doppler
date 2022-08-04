# Global Terraform

This contains the terraform to create a global accelerator that currently directs traffic to us-east-1 and us-west-2 but could be expanded 

## Included Files

- `main.tf`  
  The main entry point for the Terraform run.

- `variables.tf`  
  Common variables to use in various Terraform files.

## Usage

Typically, the base Terraform will only need to be run once, and then should only
need changes very infrequently.

```
# Sets up Terraform to run
$ terraform init

# Executes the Terraform run
$ terraform apply
```

## Variables

| Name                 | Description                                                                                                                                                                                                                                                                                                                 |  Type  |   Default   | Required |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----: | :---------: | :------: |
| app                  | Name of the application. This value should usually match the application tag below.                                                                                                                                                                                                                                         | string |             |   yes    |
| aws_profile          | The AWS profile to use, this would be the same value used in AWS_PROFILE.                                                                                                                                                                                                                                                   | string |             |   yes    |
| image_tag_mutability | The tag mutability setting for the repository.                                                                                                                                                                                                                                                                              | string |  IMMUTABLE  |          |
| region               | The AWS region to use for the bucket and registry; typically `us-east-1`. Other possible values: `us-east-2`, `us-west-1`, or `us-west-2`. <br>Currently, Fargate is only available in `us-east-1`.                                                                                                                         | string | `us-east-1` |          |
| saml_role            | The role that will have access to the S3 bucket, this should be a role that all members of the team have access to.                                                                                                                                                                                                         | string |             |   yes    |
| tags                 | A map of the tags to apply to various resources. The required tags are: <br>+ `application`, name of the app <br>+ `environment`, the environment being created <br>+ `team`, team responsible for the application <br>+ `contact-email`, contact email for the _team_ <br>+ `customer`, who the application was create for |  map   |   `<map>`   |   yes    |

## Outputs

| Name | Description |
| ---- | ----------- |
| ...  | ...         |

## Additional Information

- [Terraform providers][provider]

[provider]: https://www.terraform.io/docs/providers/
