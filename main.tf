module "discourse_killred_net" {
  source        = "./modules/do_discourse"
  ssh_key_name  = "wowbagger"
  site_name     = "discourse"
  domain        = "discourse.killred.net"
  droplet_count = 2
}
