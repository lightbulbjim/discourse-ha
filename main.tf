module "discourse_killred_net" {
  source        = "./modules/do_discourse"
  ssh_key_name  = "wowbagger"
  site_name     = "discourse"
  domain        = "discourse.killred.net"
  droplet_count = 2
}

# These are just here so that they end up in stdout.
output "loadbalancer_ip" {
  value       = module.discourse_killred_net.loadbalancer_ip
  description = "Public IP of the front door load balancer."
}

output "appserver_ips" {
  value       = module.discourse_killred_net.app_server_ip
  description = "Public management (SSH) IPs of the app servers."
}