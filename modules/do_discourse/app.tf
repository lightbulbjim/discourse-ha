data "template_file" "discourse_app_config" {
  template = file("${path.module}/templates/app.yml.tpl")
  vars = {
    hostname     = digitalocean_record.public.fqdn
    admin_emails = join(",", var.admin_emails)
    workers      = var.workers

    # Email
    smtp_address  = var.smtp_server
    smtp_port     = var.smtp_server_port
    smtp_user     = var.smtp_user
    smtp_password = var.smtp_password

    # Database
    db_name         = digitalocean_database_cluster.postgres.database
    db_user         = digitalocean_database_cluster.postgres.user
    db_password     = digitalocean_database_cluster.postgres.password
    db_primary_host = digitalocean_database_cluster.postgres.private_host
    db_primary_port = digitalocean_database_cluster.postgres.port
    db_replica_host = "changeme"
    db_replica_port = 12345

    # Main Redis
    redis_password     = digitalocean_database_cluster.redis.password
    redis_primary_host = digitalocean_database_cluster.redis.private_host
    redis_primary_port = digitalocean_database_cluster.redis.port
    redis_replica_host = "changeme"
    redis_replica_port = 12345

    # Message bus
    mb_redis_password     = digitalocean_database_cluster.redis.password
    mb_redis_primary_host = digitalocean_database_cluster.redis.private_host
    mb_redis_primary_port = digitalocean_database_cluster.redis.port
    mb_redis_replica_host = "changeme"
    mb_redis_replica_port = 12345
  }
}

data "template_cloudinit_config" "app" {
  # DO doesn't support gzip/base64 user_data
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-config.yml.tpl", {
      app_yml_encoded = base64encode(data.template_file.discourse_app_config.rendered)
      swap_bytes      = var.swap_gb * 1000000000
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
  name = "${var.site_name}-app"
  tags = [local.app_tag]

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
