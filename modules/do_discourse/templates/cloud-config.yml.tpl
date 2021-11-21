#cloud-config

package_update: true
package_upgrade: true

packages:
  - docker.io

write_files:
  - path: /root/app.yml
    owner: root:root
    permissions: '0644'
    encoding: b64
    content: ${app_yml_encoded}

runcmd:
  - git clone https://github.com/discourse/discourse_docker.git /var/discourse
  - cd /var/discourse

final_message: "Provisioning complete after $UPTIME seconds."