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


## Domain Notes

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


## Multiple Instances

If creating multiple instances:

1. Each instance must have a unique `site_name`, otherwise resources will collide.
2. Each instance should have unique SMTP and Spaces credentials.


## Database Scaling

The Postgres and Redis clusters are setup with two nodes in a active/standby arrangement. DigitalOcean handle the failover [automatically](https://docs.digitalocean.com/products/databases/#high-availability).

Note that there are no read replicas defined (although DigitalOcean do support them). The multi-node configuration is for HA, not performance.


## App Server Provisioning

This demo focuses on the infrastructure, so the provisioning of the app servers is a little under-engineered. Specifically, a vanilla vendor image is used and all provisioning happens via cloud-init at first boot. This raises the following concerns:

1. It's hard to test without deploying.
2. Secrets end up in DigitalOcean's metadata service.
3. First boot takes a long time, as Discourse goes through it's build/minify process.
4. Things are downloaded onto the app nodes first boot provisioning, adding outside dependencies.
5. Setup tasks like Rails DB migrations are performed on all app servers concurrently. This hasn't caused any problems for me (yet) but is not ideal and probably unnecessary.

In a production environment it would be better to:

1. Have an image bakery which takes a base image, performs any provisioning steps and then saves the resulting image.
2. The baked image would be used when creating app servers.
3. A minimal amount of customisation would be injected on boot to customise the server.
4. Secrets would be managed by a dedicated service (eg Vault).


## Maintenance/Outage Page

There is none. If there are no healthy app servers then you will see a raw unstyled 503 page from the load balancer.


## Rough Edges

### Using Let's Encrypt certificates in dev

Let's Encrypt is used to generate the main TLS certificate and imposes [rate limits](https://letsencrypt.org/docs/rate-limits/). Each time the certificate resource is created a new certificate is requested from Let's Encrypt, so if you iterate through many destroy/create cycles (likely during development) you may hit the limit.


### CDN

Static assets and uploads are stored and served from DigitalOcean's Spaces object store. Ideally this would be fronted by a CDN, however DigitalOcean's CDN has a quirk where it always returns a garbled (compressed?) for JS files. This is a [known problem](https://meta.discourse.org/t/using-object-storage-for-uploads-s3-clones/148916#digital-ocean-spaces).

To work around this, the CDN has been bypassed. Discourse is configured as if there is a CDN, but the configured (unbranded) hostname is actually that of the Spaces bucket. The bucket hostname has also been added to the CSP `script-src` value. 


## Todo

* Re-enable Let's Encrypt
* Test failover
