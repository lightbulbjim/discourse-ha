output "discourse0_ip" {
  value = digitalocean_droplet.discourse0.ipv4_address
}

output "loadbalancer_ip" {
  value = digitalocean_loadbalancer.public.ip
}
