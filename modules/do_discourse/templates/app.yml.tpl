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
  DISCOURSE_FORCE_HTTPS: true
  DISCOURSE_DEVELOPER_EMAILS: '${admin_emails}'
  UNICORN_WORKERS: ${workers}

  DISCOURSE_SMTP_ADDRESS: ${smtp_address}
  DISCOURSE_SMTP_PORT: ${smtp_port}
  DISCOURSE_SMTP_USER_NAME: ${smtp_user}
  DISCOURSE_SMTP_PASSWORD: ${smtp_password}
  DISCOURSE_SMTP_ENABLE_START_TLS: true
  DISCOURSE_SMTP_DOMAIN: ${hostname}
  DISCOURSE_NOTIFICATION_EMAIL: noreply@${hostname}

  DISCOURSE_DB_HOST: ${db_host}
  DISCOURSE_DB_PORT: ${db_port}
  DISCOURSE_DB_USERNAME: ${db_user}
  DISCOURSE_DB_PASSWORD: ${db_password}
  DISCOURSE_DB_NAME: ${db_name}

  DISCOURSE_REDIS_HOST: ${redis_host}
  DISCOURSE_REDIS_PORT: ${redis_port}
  DISCOURSE_REDIS_USE_SSL: true
  DISCOURSE_REDIS_PASSWORD: ${redis_password}
  DISCOURSE_REDIS_DB: 0

  DISCOURSE_MESSAGE_BUS_REDIS_HOST: ${mb_redis_host}
  DISCOURSE_MESSAGE_BUS_REDIS_PORT: ${mb_redis_port}
  DISCOURSE_MESSAGE_BUS_REDIS_PASSWORD: ${mb_redis_password}
  DISCOURSE_MESSAGE_BUS_REDIS_DB: 1

  DISCOURSE_USE_S3: true
  DISCOURSE_S3_REGION: ${region}
  DISCOURSE_S3_ENDPOINT: https://${region}.digitaloceanspaces.com
  DISCOURSE_S3_ACCESS_KEY_ID: ${spaces_access_key_id}
  DISCOURSE_S3_SECRET_ACCESS_KEY: ${spaces_secret_access_key}
  DISCOURSE_S3_CDN_URL: https://${spaces_bucket_domain}
  DISCOURSE_S3_BUCKET: ${spaces_bucket_name}
  DISCOURSE_BACKUP_LOCATION: s3
  DISCOURSE_S3_BACKUP_BUCKET: ${spaces_bucket_name}/backups

volumes:
  - volume:
      host: /var/discourse/shared/web-only
      guest: /shared
  - volume:
      host: /var/discourse/shared/web-only/log/var-log
      guest: /var/log

hooks:
  after_assets_precompile:
    - exec:
        cd: $home
        cmd:
          - sudo -E -u discourse bundle exec rake s3:upload_assets