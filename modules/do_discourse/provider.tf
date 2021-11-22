terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }

    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.2"
    }
  }
}

data "digitalocean_ssh_key" "terraform" {
  name = var.ssh_key_name
}