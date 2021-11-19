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
    entry_protocol   = "https"
    entry_port       = 443
    certificate_name = digitalocean_certificate.public.name

    target_protocol = "http"
    target_port     = 80
  }

  # Healthcheck once an app is running.
}

resource "digitalocean_droplet" "discourse0" {
  name     = "discourse0"
  tags     = ["discourse-app"]
  region   = local.region
  image    = local.droplet_image
  size     = local.droplet_size
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]
}

resource "digitalocean_firewall" "firewall" {
  name = "ssh-only"
  tags = ["discourse-app"]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}