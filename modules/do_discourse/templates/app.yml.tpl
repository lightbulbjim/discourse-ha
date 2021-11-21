templates:
  - "templates/web.template.yml"
  - "templates/web.ratelimited.template.yml"

expose:
  - "80:80"

env:
  LC_ALL: en_US.UTF-8
  LANG: en_US.UTF-8
  LANGUAGE: en_US.UTF-8
  EMBER_CLI_PROD_ASSETS: 1
  DISCOURSE_HOSTNAME: ${hostname}
  DISCOURSE_DEVELOPER_EMAILS: '${admin_emails}'
  UNICORN_WORKERS: ${workers}

  DISCOURSE_SMTP_ADDRESS: ${smtp_address}
  DISCOURSE_SMTP_PORT: ${smtp_port}
  DISCOURSE_SMTP_USER_NAME: ${smtp_user}
  DISCOURSE_SMTP_PASSWORD: ${smtp_password}
  DISCOURSE_SMTP_ENABLE_START_TLS: true
  DISCOURSE_SMTP_DOMAIN: ${hostname}
  DISCOURSE_NOTIFICATION_EMAIL: noreply@${hostname}

  DISCOURSE_DB_NAME: ${db_name}
  DISCOURSE_DB_USERNAME: ${db_user}
  DISCOURSE_DB_PASSWORD: ${db_password}
  DISCOURSE_DB_HOST: ${db_primary_host}
  DISCOURSE_DB_PORT: ${db_primary_port}

  DISCOURSE_REDIS_DB: 0
  DISCOURSE_REDIS_PASSWORD: ${redis_password}
  DISCOURSE_REDIS_HOST: ${redis_primary_host}
  DISCOURSE_REDIS_PORT: ${redis_primary_port}
  DISCOURSE_REDIS_USE_SSL: true

  ## The http or https CDN address for this Discourse instance (configured to pull)
  ## see https://meta.discourse.org/t/14857 for details
  #DISCOURSE_CDN_URL: https://discourse-cdn.example.com

volumes:
  - volume:
      host: /var/discourse/shared/web-only
      guest: /shared
  - volume:
      host: /var/discourse/shared/web-only/log/var-log
      guest: /var/log
