resource "digitalocean_droplet" "discourse1" {
  name = "discourse1"
  user_data = file("cloud-init.yaml")
  region = local.region
  image = local.droplet_image
  size = local.droplet_size
  ssh_keys = [ data.digitalocean_ssh_key.terraform.id ]
}