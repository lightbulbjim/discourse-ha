# The DB nodes sometimes take longer to boot than expected, causing the
# firewall creation to fail. Ugly, yes.
resource "time_sleep" "wait_30_seconds" {
  depends_on = [
    digitalocean_database_cluster.postgres,
    digitalocean_database_cluster.redis
  ]
  create_duration = "30s"
}

resource "digitalocean_database_cluster" "postgres" {
  name                 = "${var.site_name}-postgres"
  region               = var.region
  private_network_uuid = digitalocean_vpc.main.id
  engine               = "pg"
  version              = "13"
  size                 = var.postgres_droplet_size
  node_count           = 2
}

resource "digitalocean_database_firewall" "postgres" {
  depends_on = [time_sleep.wait_30_seconds]
  cluster_id = digitalocean_database_cluster.postgres.id
  rule {
    type  = "tag"
    value = local.app_tag
  }
}

resource "digitalocean_database_cluster" "redis" {
  name                 = "${var.site_name}-redis"
  region               = var.region
  private_network_uuid = digitalocean_vpc.main.id
  engine               = "redis"
  version              = "6"
  size                 = var.redis_droplet_size
  node_count           = 2
}

resource "digitalocean_database_firewall" "redis" {
  depends_on = [time_sleep.wait_30_seconds]
  cluster_id = digitalocean_database_cluster.redis.id
  rule {
    type  = "tag"
    value = local.app_tag
  }
}

# Bucket name needs to be unique.
resource "random_id" "id" {
  byte_length = 8
}

resource "digitalocean_spaces_bucket" "assets" {
  name          = "${var.site_name}-assets-${random_id.id.hex}"
  region        = var.region
  force_destroy = true
}