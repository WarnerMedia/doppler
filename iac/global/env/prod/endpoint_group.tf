# Endpoint groups
# As we add more environments, we'll need to add them here to be a part of ga

resource "aws_globalaccelerator_endpoint_group" "doppler_us_east_1" {
  listener_arn                  = aws_globalaccelerator_listener.doppler.id
  health_check_path             = var.health_check
  health_check_port             = 443
  health_check_interval_seconds = 30
  health_check_protocol         = "TCP"
  endpoint_group_region         = "us-east-1"
  traffic_dial_percentage       = 100

  // us east 1
  endpoint_configuration {
    client_ip_preservation_enabled = true
    endpoint_id                    = var.us_east_1_lb_arn
    weight                         = 100
  }
}

resource "aws_globalaccelerator_endpoint_group" "doppler_us_west_2" {
  listener_arn                  = aws_globalaccelerator_listener.doppler.id
  health_check_path             = var.health_check
  health_check_port             = 443
  health_check_interval_seconds = 30
  health_check_protocol         = "TCP"
  endpoint_group_region         = "us-west-2"
  traffic_dial_percentage       = 100

  // us west 2
  endpoint_configuration {
    client_ip_preservation_enabled = true
    endpoint_id                    = var.us_west_2_lb_arn
    weight                         = 100
  }
}
