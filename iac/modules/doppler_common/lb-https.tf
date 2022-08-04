# adds an https listener to the load balancer
# (delete this file if you only want http)

# The port to listen on for HTTPS, always use 443
variable "https_port" {
  default = "443"
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.main.id
  port              = var.https_port
  protocol          = "HTTPS"
  certificate_arn   = module.cert.certificate_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.id
  }
}

resource "aws_security_group_rule" "ingress_lb_https" {
  type              = "ingress"
  description       = "HTTPS"
  from_port         = var.https_port
  to_port           = var.https_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_lb.id
}

locals {
  subdomain = "${var.environment}.modules.${var.hosted_zone}"
}

resource "aws_route53_record" "app" {
  zone_id = var.route53_zone_id
  type    = "CNAME"
  name    = local.subdomain
  records = [aws_alb.main.dns_name]
  ttl     = "30"
}

module "cert" {
  source       = "../certificate"
  domain_name  = aws_route53_record.app.name
  zone_id      = var.route53_zone_id
  alb_listener = aws_alb_listener.https
}

module "additional_cert" {
  source       = "../certificate"
  domain_name  = var.common_subdomain
  zone_id      = var.route53_zone_id
  alb_listener = aws_alb_listener.https
}

module "identity_cert" {
  source       = "../certificate"
  domain_name  = var.identity_domain
  zone_id      = var.identity_zone_id
  alb_listener = aws_alb_listener.https
}

module "telemetry_cert" {
  source       = "../certificate"
  domain_name  = var.telemetry_domain
  zone_id      = var.telemetry_zone_id
  alb_listener = aws_alb_listener.https
}
