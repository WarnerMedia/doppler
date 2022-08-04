# app/env to scaffold
app         = "${APP_NAME}"
environment = "prodga"

health_check         = "/health"
region               = "us-west-2"
aws_profile          = "" 
saml_role            = "" 

flow_logs_bucket_name   = "doppler-${APP_NAME}-prod-ga-flow-logs"

us_east_1_lb_arn        = ""
us_west_2_lb_arn        = ""

tags = {
  application   = ""
  customer      = ""
  contact-email = ""
  environment   = ""
  team          = ""
}
