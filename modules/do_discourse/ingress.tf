resource "digitalocean_vpc" "main" {
  name   = var.site_name
  region = var.region
}

# Hit the Let's Encrypt rate limit, oops!
# Using a self-signed cert for now.
resource "digitalocean_certificate" "public" {
  name = "${var.site_name}-public"
  #type    = "lets_encrypt"
  #domains = [digitalocean_record.public.fqdn]
  private_key      = file("../ssl/discourse.key")
  leaf_certificate = file("../ssl/discourse.crt")
}

resource "digitalocean_loadbalancer" "public" {
  name        = "${var.site_name}-public"
  region      = var.region
  vpc_uuid    = digitalocean_vpc.main.id
  size        = var.loadbalancer_size
  droplet_tag = local.app_tag

  redirect_http_to_https = true
  forwarding_rule {
    # This rule always hits the HTTP -> HTTPS redirect.
    entry_port      = 80
    entry_protocol  = "http"
    target_port     = 80
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port       = 443
    entry_protocol   = "https"
    certificate_name = digitalocean_certificate.public.name

    target_port     = 80
    target_protocol = "http"
  }

  healthcheck {
    port     = 80
    protocol = "http"
    path     = "/"

    # These are setup for fast development rather than production.
    check_interval_seconds   = 3
    response_timeout_seconds = 5
    unhealthy_threshold      = 2
    healthy_threshold        = 2
  }
}

resource "digitalocean_record" "public" {
  domain = var.domain
  type   = "A"
  name   = var.subdomain
  ttl    = 300 # For dev.
  value  = digitalocean_loadbalancer.public.ip
}
