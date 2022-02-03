locals {
  label = "grafana-${var.environment}-${var.project_namespace}"
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

# Since the docker-compose.yml and grafana config files are loaded here,
# the following user_data is needed, as opposed to configuring everything
# from the packer file.
# An alternative would be to configure your own Docker image and pull that
# through the compose file via your image registry like ECR. This would be
# the preferred approach since debugging this user_data is 🤯
locals {
  grafana_root = "/home/${var.ops_user}/grafana-dashboard"
  user_data    = <<EOS
#!/bin/bash
set -euo pipefail

su ${var.ops_user}  <<'RUNASUSER'
DOCKER_FILE=/home/${var.ops_user}/docker-compose.yml
GRAFANA_CONFIG=${local.grafana_root}/grafana.ini

# Install docker compose v2
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v${var.compose_version}/docker-compose-linux-arm64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

# Prepare folders
mkdir -p ${local.grafana_root}
sudo mkdir -p /var/{lib,log}/grafana
sudo chown -R 472:root /var/{lib,log}/grafana
sudo chmod -R 755 /var/{lib,log}/grafana

# Prepare config files
if [ ! -f "$DOCKER_FILE" ]; then
    echo '${data.template_file.docker_compose_file.rendered}' > $DOCKER_FILE
fi
if [ ! -f "$GRAFANA_CONFIG" ]; then
    echo '${data.template_file.grafana_ini.rendered}' > $GRAFANA_CONFIG
fi

# Add this user to docker group
sudo usermod -a -G docker ${var.ops_user}

# Set up this docker-compose as a systemd service
cat <<-TEMPLATE | sudo tee -a /etc/systemd/system/grafana.service
[Unit]
Description="Grafana service"
Requires=docker.service
After=network.target docker.service

[Service]
Type=simple
User=${var.ops_user}
Environment=GRAFANA_PROXY_PORT=${var.grafana_proxy_port}
Environment=GRAFANA_ROOT=${local.grafana_root}
ExecStart=/usr/bin/docker compose -f /home/${var.ops_user}/docker-compose.yml up
Restart=on-failure

[Install]
WantedBy=multi-user.target
TEMPLATE

sudo systemctl start grafana.service
RUNASUSER

EOS
}


resource "aws_key_pair" "local" {
  count      = var.instance_key_name_local == "" ? 0 : 1
  key_name   = var.instance_key_name_local
  public_key = var.instance_key_pub != "" ? var.instance_key_pub : file("~/.ssh/${var.instance_key_name_local}.pub")
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
  version = "~> 3.0.0"

  name          = "ec2-${local.label}"
  ami           = var.instance_ami_id != "" ? var.instance_ami_id : data.aws_ami.this.id
  instance_type = var.instance_type

  key_name   = var.instance_key_name_local != "" ? var.instance_key_name_local : var.instance_key_name_aws
  monitoring = true
  vpc_security_group_ids = concat(
    [aws_security_group.grafana_proxy_public_this.id],
    var.instance_ssh_enabled != "true" ? [] : [aws_security_group.grafana_ssh_public_this[0].id]
  )
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
  tags = { "Name" : "ec2-${local.label}", "Environment" : var.environment }
}
