resource "digitalocean_droplet" "app" {
  count    = var.droplet_count
  name     = "${var.site_name}-app${count.index}"
  region   = var.region
  vpc_uuid = digitalocean_vpc.main.id
  image    = var.droplet_image
  size     = var.droplet_size
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
  #  user_data = templatefile("cloud-config.yml.tpl", {})
  tags = [local.app_tag]
}

# Simple name for SSH management.
resource "digitalocean_record" "management" {
  count  = var.droplet_count
  domain = var.domain
  type   = "A"
  name   = "app${count.index}.${digitalocean_record.public.fqdn}."
  ttl    = 60
  value  = digitalocean_droplet.app[count.index].ipv4_address
}

output "app_server_management_names" {
  value = digitalocean_record.management.*.fqdn
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
