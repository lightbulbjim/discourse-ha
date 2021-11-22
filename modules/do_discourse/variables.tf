variable "site_name" {
  description = "Unique name for this Discourse site. Used to identify resources."
  type        = string
  default     = "discourse"
}

variable "ssh_key_name" {
  description = "Name of an SSH key in your DigitalOcean account."
  type        = string
}

variable "spaces_access_id" {
  description = "DigitalOcean Spaces access key ID. Should be different per site."
  type        = string
  sensitive   = true
}

variable "spaces_secret_key" {
  description = "DigitalOcean Spaces secret key. Should be different per site."
  type        = string
  sensitive   = true
}

# The domain must be preexisting in the account. Don't want to accidentally
# destroy it and leave a dangling delegation behind.
variable "domain" {
  description = "DNS domain in your DigitalOcean account."
  type        = string
  default     = "discourse.example.com"
}

variable "subdomain" {
  description = "Subdomain which the site will listen on. Use @ for apex."
  type        = string
  default     = "@"
}

variable "region" {
  description = "DigitalOcean region to deploy to."
  type        = string
  default     = "sgp1"
}

variable "loadbalancer_size" {
  description = "Size of the load balancer."
  type        = string
  default     = "lb-small"
}

variable "droplet_count" {
  description = "Number of app servers to run."
  type        = number
  default     = 1
}

variable "droplet_image" {
  description = "Droplet image to use for app servers."
  type        = string
  default     = "debian-11-x64"
}

variable "droplet_size" {
  description = "Droplet size to use for app servers."
  type        = string
  default     = "s-1vcpu-2gb"
}

variable "swap_gb" {
  description = "Size of swap file (in GB) on app servers."
  type        = number
  default     = 2
}

variable "postgres_droplet_size" {
  description = "Droplet size to use for Postgres nodes."
  type        = string
  default     = "db-s-1vcpu-2gb" # Minimum size required for active + standby.
}

variable "redis_droplet_size" {
  description = "Droplet size to use for Redis nodes."
  type        = string
  default     = "db-s-1vcpu-2gb" # Minimum size required for active + standby.
}


variable "smtp_server" {
  description = "ESP SMTP server."
  type        = string
  default     = "smtp.sendgrid.net"
}

variable "smtp_server_port" {
  description = "ESP SMTP server port."
  type        = number
  default     = 587
}

variable "smtp_user" {
  description = "ESP user name."
  type        = string
  default     = "apikey"
}

variable "smtp_password" {
  description = "ESP password."
  type        = string
  sensitive   = true
}

variable "email_cnames" {
  description = "Any required ESP CNAME records. `name` must be fully qualified."
  type = list(object({
    name  = string
    value = string
  }))
}

variable "workers" {
  description = "Number of Unicorn workers per app server."
  type        = number
  default     = 2
}

variable "admin_emails" {
  description = "List of email addresses that will be made admin in Discourse."
  type        = list(string)
}

locals {
  app_tag = "${var.site_name}-app"
}
