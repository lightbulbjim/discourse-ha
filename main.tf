resource "digitalocean_droplet" "discourse_primary" {
  name = "discourse-primary"
  region = local.region
  image = local.droplet_image
  size = local.droplet_size
  ssh_keys = [ data.digitalocean_ssh_key.terraform.id ]
}