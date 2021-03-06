data "template_file" "discourse_app_config" {
  template = file("${path.module}/templates/app.yml.tpl")
  vars = {
    discourse_version = var.discourse_version
    hostname          = digitalocean_record.public.fqdn
    admin_emails      = join(",", var.admin_emails)
    workers           = var.workers
    region            = var.region

    # Email
    smtp_address         = var.smtp_server
    smtp_port            = var.smtp_server_port
    smtp_user            = var.smtp_user
    smtp_password        = var.smtp_password
    email_sending_domain = var.email_sending_domain

    # Database
    db_host     = digitalocean_database_cluster.postgres.private_host
    db_port     = digitalocean_database_cluster.postgres.port
    db_user     = digitalocean_database_cluster.postgres.user
    db_password = digitalocean_database_cluster.postgres.password
    db_name     = digitalocean_database_cluster.postgres.database

    # Main Redis
    redis_host     = digitalocean_database_cluster.redis.private_host
    redis_port     = digitalocean_database_cluster.redis.port
    redis_password = digitalocean_database_cluster.redis.password

    # Message bus
    mb_redis_host     = digitalocean_database_cluster.redis.private_host
    mb_redis_port     = digitalocean_database_cluster.redis.port
    mb_redis_password = digitalocean_database_cluster.redis.password

    # Object storage
    spaces_access_key_id     = var.spaces_access_id
    spaces_secret_access_key = var.spaces_secret_key
    spaces_bucket_name       = digitalocean_spaces_bucket.assets.name
    spaces_bucket_domain     = digitalocean_spaces_bucket.assets.bucket_domain_name
  }
}

data "template_cloudinit_config" "app" {
  # DO doesn't support gzip/base64 user_data
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-config.yml.tpl", {
      app_yml_encoded          = base64encode(data.template_file.discourse_app_config.rendered)
      swap_bytes               = var.swap_gb * 1000000000
      discourse_docker_version = var.discourse_docker_version
    })
  }
}

resource "digitalocean_droplet" "app" {
  count     = var.droplet_count
  name      = "${var.site_name}-app${count.index}"
  region    = var.region
  vpc_uuid  = digitalocean_vpc.main.id
  image     = var.droplet_image
  size      = var.droplet_size
  ssh_keys  = [data.digitalocean_ssh_key.terraform.id]
  user_data = data.template_cloudinit_config.app.rendered
  tags      = [local.app_tag]

  lifecycle {
    create_before_destroy = true
  }
}

# Convenience record for SSH management.
resource "digitalocean_record" "management" {
  count  = var.droplet_count
  domain = var.domain
  type   = "A"
  name   = "app${count.index}.${digitalocean_record.public.fqdn}."
  ttl    = 60
  value  = digitalocean_droplet.app[count.index].ipv4_address
}

resource "digitalocean_firewall" "app_firewall" {
  depends_on = [digitalocean_droplet.app]
  name       = "${var.site_name}-app"
  tags       = [local.app_tag]

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol                  = "tcp"
    port_range                = "80"
    source_load_balancer_uids = [digitalocean_loadbalancer.public.id]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

//noinspection HILUnresolvedReference
resource "digitalocean_record" "email" {
  for_each = { for i, v in var.email_cnames : i => v } # Oh Terraform...
  domain   = var.domain
  type     = "CNAME"
  name     = each.value.name
  ttl      = 300
  value    = each.value.value
}
