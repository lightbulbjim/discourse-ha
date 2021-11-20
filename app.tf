resource "digitalocean_firewall" "app_firewall" {
  name = "discourse-app"
  tags = ["discourse-app"]

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

resource "digitalocean_droplet" "discourse0" {
  name      = "discourse0"
  region    = local.region
  vpc_uuid  = digitalocean_vpc.discourse.id
  image     = local.droplet_image
  size      = local.droplet_size
  ssh_keys  = [data.digitalocean_ssh_key.terraform.id]
  user_data = templatefile("cloud-config.yml.tpl", {})
  tags      = ["discourse-app"]
}

output "discourse0_ip" {
  value = digitalocean_droplet.discourse0.ipv4_address
}
