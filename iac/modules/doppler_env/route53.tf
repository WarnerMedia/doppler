data "aws_route53_zone" "app" {
  name = var.hosted_zone
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.app.zone_id
  type    = "A"
  name    = var.common_subdomain

  alias {
    name                   = aws_globalaccelerator_accelerator.doppler.dns_name
    zone_id                = aws_globalaccelerator_accelerator.doppler.hosted_zone_id
    evaluate_target_health = true
  }
}
