# doppler_env

## Parent module of children modules doppler_source and doppler_destination

### Contains terraform files for resources to create the dev environment

alarms.tf - creates cloudwatch alarms for all regions supported; moved to this level due to customization difference in dev, test, and prod
dashboard.tf - creates cloudwatch dashboard for all regions supported; this is at this module level due to the desire to have one dashboard for all suppoerted regions
globalaccelerator.tf - creates the global accelerator to allow direction of traffic to each region.
main.tf - main entrypoint into module
provider.tf - this contains the providers for each stack. Currently has only us-east-1 and us-west-2.
route53.tf - creates the common subdomain used by all the regions.
variables.tf - variables needed by this module.
versions.tf - controls versioning of terraform resources
