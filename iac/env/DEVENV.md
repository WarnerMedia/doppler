# How to create your own dev environment that is literally exactly like prod

## Creating the resources

1. Copy the dev directory in your own directory.

   ```text
   cp -R ./dev ./devuser
   ```

2. Change directory into devuser.

3. Edit main.tf.

   - Change line 43(key = "dev.terraform.tfstate") from dev.terraform.tfstate to something else unique. (ex. xyzpdq.terrafrom.tfstate).

4. Edit terraform.tfvars.

   - Change line 12(common_subdomain = "dev.${DOMAIN_NAME}") from dev.${DOMAIN_NAME} to something else unique. (ex. xyzpdq.${DOMAIN_NAME})
   - Change line 20(environment = "dev") from dev to something else unique. (ex. dvms)
   - Change line 23(common_environment = "dev") from dev to something else unique. (ex. dvms)
   - Change line 28(environment_us_east_1 = "devuseast1") from devuseast1 to something else unique. (ex. dvmsuseast1)
   - Change line 33(target_bucket_name_us_east_1 = "doppler-${APP_NAME}-dev-useast1") from doppler-${APP_NAME}-dev-useast1 to something else unique. (ex. doppler-${APP_NAME}-dvms-useast1)
   - Change line 37(environment_us_west_2 = "devuswest2") from devuswest2 to something else unique. (ex. dvmsuswest2)
   - Change line 42(target_bucket_name_us_west_2 = "doppler-${APP_NAME}-dev-uswest2") from doppler-${APP_NAME}-dev-uswest2 to something else unique. (ex. doppler-${APP_NAME}-dvms-uswest2)


   ```text
   terraform init
   ```

6. Now its time to plan out the terraform to verify that everything looks clean.

   ```text
   terraform plan
   ```

7. If everything looks, go ahead and apply the terraform.

   ```text
   terraform apply
   ```

8. Once this has completed you have a complete doppler environment.

## Deploying the code to fargate

1. Change directory over to the code's http_handler directory.

   ```text
   cd ../../code/http_handler
   ```

2. Edit deploy_east_dev.sh.

   - Change line 24(fargate service deploy -f deploy_east_dev.yml --cluster doppler-${APP_NAME}-devuseast1 --service doppler-${APP_NAME}-devuseast1 --wait-for-service) from devuseast1 to whatever you named it in step 4(line 28). So in the example above I would change devuseast1 to dvmsuseast1.

3. Change directory into the config directory.

   ```text
   cd config
   ```

4. Edit dev_east.env

   - Change line 3(ENVIRONMENT=devuseast1) from devuseast1 to whatever you named it in step 4(line 28). So in the example above I would change devuseast1 to dvmsuseast1.
   - Change line 8(METRIC_PREFIX=doppler-${APP_NAME}-devuseast1) from devuseast1 to whatever you named it in step 4(line 28). So in the example above I would change devuseast1 to dvmsuseast1.
   - Change line 8(DLQ_URL=https://sqs.us-east-1.amazonaws.com/${AWS_ACCOUNT}/doppler-${APP_NAME}-devuseast1-dlq) from devuseast1 to whatever you named it in step 4(line 28). So in the example above I would change devuseast1 to dvmsuseast1.

5. Assuming you have the pip awscli installed, run can now run the deploy script in Step 2.

   ```text
   ./deploy_east_dev.sh
   ```

6. Once everything is deployed you should be able to run the test.sh script in the tests directory against your endpoint and watch some data land in s3.

**If you want to test out the global portion of this stack, you can repeat steps 1 through 5 above for the deploy_west_dev.sh and the dev_west.env files.  I won't get into detail about adjusting traffic in global accelerator or watching s3 data replicate from the west s3 bucket to the east s3 bucket but it does work and you can play around with it**
