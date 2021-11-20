module "discourse_killred_net" {
  source        = "./modules/do_discourse"
  ssh_key_name  = "wowbagger"
  site_name     = "discourse"
  domain        = "discourse.killred.net"
  droplet_count = 2
}

# These are just here so that they end up in stdout.
output "loadbalancer_ip" {
  description = "Public IP of the front door load balancer."
  value       = module.discourse_killred_net.loadbalancer_ip
}

output "app_server_management_names" {
  description = "Public management (SSH) names of the app servers."
  value       = module.discourse_killred_net.app_server_management_names
}