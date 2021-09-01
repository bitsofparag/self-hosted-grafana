locals {
  label = "grafana-${var.project_namespace}"
}


resource "random_string" "grafana_user" {
  length  = 8
  special = false
}

resource "random_password" "grafana_password" {
  length           = 15
  special          = true
  override_special = "_%@"
}


data "template_file" "docker_compose_file" {
  template = file("${path.module}/files/docker-compose.tmpl.yml")

  vars = {
    domain  = var.grafana_domain
    version = var.grafana_version
  }
}

data "template_file" "grafana_ini" {
  template = file("${path.module}/files/grafana.tmpl.ini")

  vars = {
    domain   = var.grafana_domain
    password = random_password.grafana_password.result
    user     = random_string.grafana_user.result
  }
}

locals {
  grafana_root = "/home/${var.ops_user}/grafana-dashboard"
  user_data    = <<EOF
#!/bin/bash

su ${var.ops_user}  <<'RUNASUSER'
DOCKER_FILE=/home/${var.ops_user}/docker-compose.yml
GRAFANA_CONFIG=${local.grafana_root}/grafana.ini

sudo usermod -a -G docker ${var.ops_user}
sudo mkdir -p /var/lib/grafana
sudo chown -R 472:root /var/lib/grafana
sudo chown -R 472:root /var/log/grafana
sudo chmod -R 755 /var/lib/grafana
sudo chmod -R 755 /var/log/grafana
mkdir -p ${local.grafana_root}
cd ${local.grafana_root}
echo "export GRAFANA_PROXY_PORT=${var.grafana_proxy_port}" >> /home/${var.ops_user}/.bashrc
echo "export GRAFANA_ROOT=${local.grafana_root}" >> /home/${var.ops_user}/.bashrc

if [ ! -f "$DOCKER_FILE" ]; then
    echo '${data.template_file.docker_compose_file.rendered}' > $DOCKER_FILE
fi

if [ ! -f "$GRAFANA_CONFIG" ]; then
    echo '${data.template_file.grafana_ini.rendered}' > $GRAFANA_CONFIG
fi
docker-compose up -d
RUNASUSER

EOF
}


resource "aws_key_pair" "ec2_grafana" {
  count      = var.instance_key_name != "" ? 1 : 0
  key_name   = var.instance_key_name
  public_key = file("~/.ssh/${var.instance_key_name}.pub")
}


# https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateSecurityGroup.html
resource "aws_security_group" "grafana_proxy_public_this" {
  vpc_id = local.vpc_id
  name   = "sec-grp-${local.label}"

  ingress {
    from_port   = var.grafana_proxy_port
    to_port     = var.grafana_proxy_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "public to ec2 (via assigned port)"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "public ssh to ec2 (via 22)"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "ec2 to public"
  }

  tags = { "Name" : "sec-grp-${local.label}" }
}


data "aws_ami" "this" {
  owners = ["self"]
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "tag:Name"
    values = [var.instance_ami_name]
  }
  most_recent = true
}


# Source: https://github.com/terraform-aws-modules/terraform-aws-ec2-instance
# Creates an EBS-optimized, General purpose EC2 instance (but no addl. volume attached)
module "grafana_dashboard" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.19.0"

  name           = "ec2-${local.label}"
  instance_count = 1
  ami            = var.instance_ami_id != "" ? var.instance_ami_id : data.aws_ami.this.id
  instance_type  = var.instance_type

  key_name   = var.instance_key_name != "" ? var.instance_key_name : "auto-generated"
  monitoring = true
  vpc_security_group_ids = [
    aws_security_group.grafana_proxy_public_this.id
  ]
  subnet_id                   = local.subnet_id
  associate_public_ip_address = true
  user_data_base64            = base64encode(local.user_data)
  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = var.instance_root_disk_size
      delete_on_termination = false
    }
  ]
  tags = { "Name" : "ec2-${local.label}" }
}
