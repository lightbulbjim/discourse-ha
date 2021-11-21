# Discourse Demo

This is a demo of a simple HA Discourse instance running on DigitalOcean, built using Terraform.

Everything is wrapped in a Terraform module in an attempt for cleanliness. This means it should be possible to call the module several times to create multiple Discourse instances (note that all instances created will be in the same account).


## Prerequisites

To build this stack you will need the following:

1. A DigitalOcean account.
2. A DNS domain which is managed by your DigitalOcean account.
3. An ESP (email service provider) account for outgoing email. Tested with SendGrid, but should work with any which allow you to send via authenticated SMTP over TLS.
4. The DNS domain from step 2 configured as a sending domain in the ESP.


## Using the Module

Secrets are specified in the root `variables.tf` so that they can be passed in at runtime.

All other variables are module-level, and are defined in `modules/do_discourse/variables.tf`. They should be self-explanatory.

The example in `main.tf` should give a good idea of what the variables look like in practice.

### Domain Notes

There are two variables used to specify the public DNS domain: `domain` and `subdomain`.

If the domain in DigitalOcean is the domain in which Discourse is going to run (ie the DNS record pointing at the front door load balancer is an apex record) the only `domain` needs to be specified (the default value of `subdomain` is `@`).

```terraform
module "example_com" {
  source = "./modules/do_discourse"
  domain = "example.com"
  ...
}
```

If Discourse is going to run on a subdomain of the managed domain, then both `domain` and `subdomain` should be specified.

```terraform
module "discourse_example_com" {
  source    = "./modules/do_discourse"
  domain    = "example.com"
  subdomain = "discourse"
  ...
}
```

### Multiple Instances

If creating multiple instances:

1. Each instance must have a unique `site_name`, otherwise resources will collide.
2. Each instance should have unique SMTP and Spaces credentials.


## Sharp Edges

Let's Encrypt is used to generate the main TLS certificate and imposes [rate limits](https://letsencrypt.org/docs/rate-limits/). Each time the certificate resource is created a new certificate is requested from Let's Encrypt, so if you iterate through many destroy/create cycles (likely during development) you may hit the limit.