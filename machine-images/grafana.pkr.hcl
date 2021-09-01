#------------------------------------------------------------------------------
# OCI-compliant image builder for webserver
# This builder prepares an Amazon AMI and provisions it with:
# - Nginx
#------------------------------------------------------------------------------
# Shared variables for packer files.
# See https://www.packer.io/docs/templates/hcl_templates/variables for more info.

# ----- shared vars
variable "provision_root" {
  type = string
  default = env("PROVISION_ROOT")
}

variable "aws_profile" {
  type    = string
  default = env("AWS_PROFILE")
}

variable "aws_region" {
  type    = string
  default = env("AWS_REGION")
}

variable "aws_access_key_id" {
  type    = string
  default = env("AWS_ACCESS_KEY_ID")
  sensitive = true
}

variable "aws_secret_access_key" {
  type    = string
  default = env("AWS_SECRET_ACCESS_KEY")
  sensitive = true
}

variable "base_ami" {
  type    = string
  default = env("UBUNTU_AMI")
}

# ----- webserver specific vars
variable "ami_name" {
  type = string
  description = "The id of the AMI image to use as webserver"
  default = "aws-grafana"

  validation {
    condition     = can(regex("^aws-grafana", var.ami_name))
    error_message = "The image_id value must be a valid AMI id, starting with \"aws-grafana\"."
  }
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "grafana_version" {
  type    = string
  default = env("GRAFANA_VERSION")
}

variable "nginx_version" {
  type    = string
  default = env("NGINX_VERSION")
}

variable "docker_compose_version" {
  type = string
  default = env("DOCKER_COMPOSE_VERSION")
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "grafana" {
  access_key                  = var.aws_access_key_id
  ami_name                    = "aws-grafana-${var.grafana_version}-${local.timestamp}"
  associate_public_ip_address = false
  instance_type               = var.instance_type
  profile                     = var.aws_profile
  region                      = var.aws_region
  secret_key                  = var.aws_secret_access_key
  source_ami                  = var.base_ami
  ssh_username                = var.ssh_username
  tags = {
    CreatedAt = local.timestamp
    Name      = var.ami_name
    Release   = "${var.grafana_version}-${local.timestamp}"
    Service   = "ami"
  }
}

source "amazon-ebs" "grafana-nginx" {
  access_key                  = var.aws_access_key_id
  ami_name                    = "aws-grafana-nginx-${var.grafana_version}-${local.timestamp}"
  associate_public_ip_address = false
  instance_type               = var.instance_type
  profile                     = var.aws_profile
  region                      = var.aws_region
  secret_key                  = var.aws_secret_access_key
  source_ami                  = var.base_ami
  ssh_username                = var.ssh_username
  tags = {
    CreatedAt = local.timestamp
    Name      = var.ami_name
    Release   = "${var.grafana_version}-${local.timestamp}"
    Service   = "ami"
  }
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  name = "grafana"
  sources = ["source.amazon-ebs.grafana"]

  provisioner "shell" {
    pause_before    = "5s"
    execute_command  = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    scripts         = ["${var.provision_root}/scripts/install/install-shared.sh"]
  }

  provisioner "shell" {
    environment_vars = ["DOCKER_COMPOSE_VERSION=${var.docker_compose_version}"]
    execute_command  = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    pause_before     = "5s"
    scripts          = ["${var.provision_root}/scripts/install/install-docker.sh"]
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    pause_before    = "5s"
    scripts         = ["${var.provision_root}/scripts/post-install/cleanup.sh"]
  }
}


build {
  name = "grafana-nginx"
  sources = ["source.amazon-ebs.grafana-nginx"]

  provisioner "shell" {
    pause_before    = "5s"
    execute_command  = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    scripts         = ["${var.provision_root}/scripts/install/install-shared.sh"]
  }

  provisioner "shell" {
    environment_vars = ["NGINX_VERSION=${var.nginx_version}"]
    execute_command  = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    pause_before     = "5s"
    scripts          = ["${var.provision_root}/scripts/install/install-nginx.sh"]
  }

  provisioner "file" {
    destination = "/tmp/nginx.conf"
    source      = "${var.provision_root}/images/files/nginx/nginx.conf"
  }

  provisioner "file" {
    destination = "/tmp"
    source      = "${var.provision_root}/images/files/nginx/vhost_includes"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    inline          = [
      "mv /tmp/vhost_includes /etc/nginx/",
      "mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "chown -R root:root /etc/nginx/*",
      "systemctl stop nginx",
      "systemctl start nginx"
    ]
  }

  provisioner "shell" {
    environment_vars = ["DOCKER_COMPOSE_VERSION=${var.docker_compose_version}"]
    execute_command  = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    pause_before     = "5s"
    scripts          = ["${var.provision_root}/scripts/install/install-docker.sh"]
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
    pause_before    = "5s"
    scripts         = ["${var.provision_root}/scripts/post-install/cleanup.sh"]
  }
}
