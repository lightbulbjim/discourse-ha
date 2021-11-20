output "loadbalancer_ip" {
  value = digitalocean_loadbalancer.public.ip
}

output "app_server_management_names" {
  value = digitalocean_record.management.*.fqdn
}