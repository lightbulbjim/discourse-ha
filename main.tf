resource "digitalocean_domain" "discourse" {
  name = "discourse.killred.net"
}

resource "digitalocean_droplet" "discourse0" {
  name     = "discourse-primary"
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