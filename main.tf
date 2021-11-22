module "discourse_killred_net" {
  source                   = "./modules/do_discourse"
  ssh_key_name             = "wowbagger"
  discourse_docker_version = "66a6ced3413d86adbf48c3f747ea5859a0172848"
  discourse_version        = "05423e9dfd77a05c7d9062aa7a5aeba8756d01f0"
  site_name                = "discourse"
  domain                   = "discourse.killred.net"
  droplet_count            = 2
  spaces_access_id         = var.spaces_access_id
  spaces_secret_key        = var.spaces_secret_key
  smtp_password            = var.sendgrid_api_key
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
  admin_emails = ["chris@killred.net"]
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