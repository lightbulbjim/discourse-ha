variable "ssh_key_name" {
  description = "Name of an SSH key in your DigitalOcean account."
  type        = string
}

variable "site_name" {
  description = "Unique string which will be used when naming resources."
  type        = string
  default     = "discourse"
}

# The domain must be preexisting in the account. Don't want to accidentally
# destroy it and leave a dangling delegation behind.
variable "domain" {
  description = "DNS domain in your DigitalOcean account."
  type        = string
  default     = "discourse.example.com"
}

variable "subdomain" {
  description = "Subdomain which the site will listen on. Can be @ for apex."
  type        = string
  default     = "@"
}

variable "region" {
  description = "DigitalOcean region to deploy to."
  type        = string
  default     = "sgp1"
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
  default     = "s-1vcpu-1gb"
}

locals {
  app_tag = "${var.site_name}-app"
}
