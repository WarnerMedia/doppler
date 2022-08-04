# Main GA Listener

resource "aws_globalaccelerator_listener" "doppler" {
  accelerator_arn = aws_globalaccelerator_accelerator.doppler.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}
