packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "git_sha" {
  type    = string
  default = "none"
}

variable "name_prefix" {
  type    = string
  default = "wrf-standalone"
}


variable "aws_access_key_id" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = ""
}

variable "aws_secret_access_key" {
  type    = string
  default = ""
}

variable "aws_vpc_id" {
  type    = string
  default = ""
}

variable "deploy_pass" {
  type    = string
  default = ""
}

variable "deploy_user" {
  type    = string
  default = ""
}

variable "ssh_keypair" {
  type = string
  default = "test"
}

variable "ssh_keypass" {
  type    = string
  default = "jared-laptop"
}

data "amazon-ami" "wrf-base" {
  access_key = "${var.aws_access_key_id}"
  filters = {
    name                = "ubuntu/images/*ubuntu-focal-22.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "${var.aws_region}"
  secret_key  = "${var.aws_secret_access_key}"
}

source "amazon-ebs" "wrf-build" {
  access_key                  = "${var.aws_access_key_id}"
  ami_name                    = "${var.name_prefix}-${var.git_sha}"
  associate_public_ip_address = true
  ena_support                 = true
  instance_type               = "c5.2xlarge"
  region                      = "${var.aws_region}"
  secret_key                  = "${var.aws_secret_access_key}"
  source_ami                  = "${data.amazon-ami.wrf-base.id}"
  ssh_agent_auth              = true
  ssh_keypair_name            = "${var.ssh_keypair}"
  ssh_username                = "ubuntu"
  vpc_id                      = "${var.aws_vpc_id}"
}

build {
  sources = ["source.amazon-ebs.wrf-build"]

  provisioner "shell" {
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  provisioner "shell" {
    scripts = [
      "scripts/install_system_deps.sh",
      "scripts/install_deps.sh",
      "scripts/build_wrf.sh"
    ]
  }

}
