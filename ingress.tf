# The actual domain is defined elsewhere. Don't want to accidentally destroy
# it and leave a dangling delegation behind.
resource "digitalocean_record" "apex" {
  domain = "discourse.killred.net"
  type   = "A"
  name   = "@"
  ttl    = 300
  value  = digitalocean_loadbalancer.public.ip
}

# Hit the Let's Encrypt rate limit, oops!
# Using a self-signed cert for now.
resource "digitalocean_certificate" "public" {
  name = "discourse-killred-net"
  #type    = "lets_encrypt"
  #domains = ["discourse.killred.net"]
  private_key      = file("../ssl/discourse.key")
  leaf_certificate = file("../ssl/discourse.crt")
}

resource "digitalocean_vpc" "discourse" {
  name   = "discourse"
  region = local.region
}

resource "digitalocean_loadbalancer" "public" {
  name        = "discourse-public"
  region      = local.region
  vpc_uuid    = digitalocean_vpc.discourse.id
  droplet_tag = "discourse-app"

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
  value = digitalocean_loadbalancer.public.ip
}
