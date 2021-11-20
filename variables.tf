variable "do_token" {
  description = "DigitalOcean API token."
  type        = string
  sensitive   = true
}

variable "spaces_access_id" {
  description = "DigitalOcean Spaces access key ID."
  type        = string
  sensitive   = true
}

variable "spaces_secret_key" {
  description = "DigitalOcean Spaces secret key."
  type        = string
  sensitive   = true
}

variable "sendgrid_api_key" {
  description = "SendGrid API key."
  type        = string
  sensitive   = true
}