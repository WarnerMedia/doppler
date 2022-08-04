# adds an http listener to the load balancer and allows ingress

resource "aws_alb_listener" "ilb_http" {
  load_balancer_arn = aws_alb.internal.id
  port              = var.lb_port
  protocol          = var.lb_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.internal.id
  }
}

resource "aws_route53_zone" "internal_alb" {
  name = "${var.environment}.modules.${var.region}.${var.app}"

  vpc {
    vpc_id = var.vpc
  }
}

resource "aws_route53_record" "dev_doppler_elb_internal_a_record" {
  zone_id = aws_route53_zone.internal_alb.zone_id
  name    = "internal.${var.environment}.modules.${var.region}.${var.app}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.internal.dns_name]
}
