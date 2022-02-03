# https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateSecurityGroup.html
resource "aws_security_group" "grafana_proxy_public_this" {
  vpc_id = local.vpc_id
  name   = "sec-grp-http-${local.label}"

  ingress {
    from_port   = var.grafana_proxy_port
    to_port     = var.grafana_proxy_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "public to ec2 (via assigned port)"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "ec2 to public"
  }

  tags = { "Name" : "sec-grp-http-${local.label}", "Environment" : var.environment }
}

# https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateSecurityGroup.html
resource "aws_security_group" "grafana_ssh_public_this" {
  count  = var.instance_ssh_enabled != "true" ? 0 : 1
  vpc_id = local.vpc_id
  name   = "sec-grp-ssh-${local.label}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "public ssh to ec2 (via 22)"
  }

  tags = { "Name" : "sec-grp-ssh-${local.label}", "Environment" : var.environment }
}
