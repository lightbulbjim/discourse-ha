resource "digitalocean_record" "public" {
  domain = var.domain
  type   = "A"
  name   = var.subdomain
  ttl    = 300 # Would make it a bit longer in prod.
  value  = digitalocean_loadbalancer.public.ip
}

# Hit the Let's Encrypt rate limit, oops!
# Using a self-signed cert for now.
resource "digitalocean_certificate" "public" {
  name = "${var.site_name}-public"
  #type    = "lets_encrypt"
  #domains = [digitalocean_record.apex.fqdn]
  private_key      = file("../ssl/discourse.key")
  leaf_certificate = file("../ssl/discourse.crt")
}

resource "digitalocean_vpc" "main" {
  name   = var.site_name
  region = var.region
}

resource "digitalocean_loadbalancer" "public" {
  name        = "${var.site_name}-public"
  region      = var.region
  vpc_uuid    = digitalocean_vpc.main.id
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
  }
}

output "loadbalancer_ip" {
  value = "${var.site_name}: ${digitalocean_loadbalancer.public.ip}"
}
