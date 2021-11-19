output "primary_ip" {
  value = "Primary droplet created: ${digitalocean_droplet.discourse_primary.ipv4_address} "
}
