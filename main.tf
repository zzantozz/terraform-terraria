variable "rax_user" {
  default = "zzantoss"
}
variable "rax_tenant" {
  default = "654720"
}
variable "no_ip_user" {
  default = "zzantozz"
}
variable "no_ip_hostname" {
  default = "stewart-terraria.hopto.org"
}
variable "region" {
  default = "DFW"
}

# Secret variables, no default
variable "rax_token" {
  sensitive = true
}
variable "no_ip_password" {
  sensitive = true
}

# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = var.rax_user
  tenant_id   = var.rax_tenant
  token       = var.rax_token
  auth_url    = "https://identity.api.rackspacecloud.com/v2.0/"
  region      = var.region
}

data "openstack_images_image_ids_v2" "latest-ubuntu-image" {
  name_regex = "(?i)ubuntu"
  sort       = "updated_at"
}

/*
  The networking resources are broken? It's trying to use a url with /v2.0/v2.0 at the end.
  I'll cover this with iptables rules.

resource "openstack_networking_secgroup_v2" "main_security_group" {
  name        = "main"
  description = "Security group for Terraria servers"
}

resource "openstack_networking_secgroup_rule_v2" "main_sg_allow_ssh" {
  security_group_id = openstack_networking_secgroup_v2.main_security_group.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "main_sg_allow_home" {
  security_group_id = openstack_networking_secgroup_v2.main_security_group.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "70.123.226.90/32"
}
*/

resource "openstack_compute_keypair_v2" "the-keypair" {
  name       = "terraria-keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "openstack_compute_instance_v2" "terraform-test" {
  name            = "terraformed-terraria-server"
  region          = var.region
  image_id        = data.openstack_images_image_ids_v2.latest-ubuntu-image.ids[0]
  flavor_id       = "general1-2"
  key_pair        = "terraria-keypair"
//  security_groups = ["main"]
  user_data = templatefile("cloud-init.sh", {
    iptables_save = base64encode(file("instance-configs/iptables-save.txt"))
    unattended_upgrades = base64encode(file("instance-configs/unattended-upgrades.txt"))
    no_ip_user = var.no_ip_user
    no_ip_password = var.no_ip_password
    no_ip_hostname = var.no_ip_hostname
  })
  depends_on = [openstack_compute_keypair_v2.the-keypair]

  network {
    uuid = "00000000-0000-0000-0000-000000000000"
    name = "public"
  }

  network {
    uuid = "11111111-1111-1111-1111-111111111111"
    name = "private"
  }
}

output "instance_ip" {
  value = openstack_compute_instance_v2.terraform-test.access_ip_v4
}
