module "discourse_killred_net" {
  source        = "./modules/do_discourse"
  ssh_key_name  = "wowbagger"
  site_name     = "discourse"
  domain        = "discourse.killred.net"
  droplet_count = 2
  smtp_password = var.sendgrid_api_key
  email_cnames = [
    {
      name  = "em3504.discourse.killred.net.",
      value = "u24288042.wl043.sendgrid.net."
    },
    {
      name  = "s1._domainkey.discourse.killred.net.",
      value = "s1.domainkey.u24288042.wl043.sendgrid.net."
    },
    {
      name  = "s2._domainkey.discourse.killred.net.",
      value = "s2.domainkey.u24288042.wl043.sendgrid.net."
    }
  ]
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