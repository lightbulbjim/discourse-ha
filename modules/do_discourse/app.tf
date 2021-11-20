resource "digitalocean_droplet" "discourse0" {
  name     = "${var.site_name}-discourse0"
  region   = var.region
  vpc_uuid = digitalocean_vpc.main.id
  image    = var.droplet_image
  size     = var.droplet_size
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
  #  user_data = templatefile("cloud-config.yml.tpl", {})
  tags = [local.app_tag]
}

output "discourse0_ip" {
  value = "${var.site_name}: ${digitalocean_droplet.discourse0.ipv4_address}"
}

resource "digitalocean_firewall" "app_firewall" {
  name = "${var.site_name}-app"
  tags = [local.app_tag]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol                  = "tcp"
    port_range                = "80"
    source_load_balancer_uids = [digitalocean_loadbalancer.public.id]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
