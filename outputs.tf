output "primary_ip" {
  value = "Primary droplet created: ${digitalocean_droplet.discourse0.ipv4_address} "
}
