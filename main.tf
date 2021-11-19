resource "digitalocean_domain" "discourse" {
  name       = "discourse.killred.net"
  ip_address = digitalocean_loadbalancer.public.ip
}

resource "digitalocean_certificate" "public" {
  name    = "discourse-certificate"
  type    = "lets_encrypt"
  domains = ["discourse.killred.net"]
}

resource "digitalocean_loadbalancer" "public" {
  name        = "discourse-public"
  region      = local.region
  droplet_tag = "discourse-app"

  redirect_http_to_https = true
  forwarding_rule {
    # This rule always hits the HTTP -> HTTPS redirect.
    entry_port      = 80
    entry_protocol  = "http"
    target_port     = 80
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port       = 443
    entry_protocol   = "https"
    certificate_name = digitalocean_certificate.public.name

    target_port     = 80
    target_protocol = "http"
  }

  # Healthcheck once an app is running.
}

resource "digitalocean_droplet" "discourse0" {
  name      = "discourse0"
  tags      = ["discourse-app"]
  region    = local.region
  image     = local.droplet_image
  size      = local.droplet_size
  ssh_keys  = [data.digitalocean_ssh_key.terraform.id]
  user_data = templatefile("cloud-config.yml.tpl", {})
}

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