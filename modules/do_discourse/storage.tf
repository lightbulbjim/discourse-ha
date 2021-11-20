resource "digitalocean_database_cluster" "postgres" {
  name                 = "${var.site_name}-postgres"
  region               = var.region
  private_network_uuid = digitalocean_vpc.main.id
  engine               = "pg"
  version              = "13"
  size                 = "db-s-1vcpu-1gb"
  node_count           = 1
}

resource "digitalocean_database_firewall" "postgres" {
  cluster_id = digitalocean_database_cluster.postgres.id
  rule {
    type  = "tag"
    value = local.app_tag
  }
}

resource "digitalocean_database_cluster" "redis" {
  name                 = "discourse"
  region               = var.region
  private_network_uuid = digitalocean_vpc.main.id
  engine               = "redis"
  version              = "6"
  size                 = "db-s-1vcpu-1gb"
  node_count           = 1
}

resource "digitalocean_database_firewall" "redis" {
  cluster_id = digitalocean_database_cluster.redis.id
  rule {
    type  = "tag"
    value = local.app_tag
  }
}
