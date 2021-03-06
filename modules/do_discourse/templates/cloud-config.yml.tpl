#cloud-config

swap:
  filename: /swap.img
  size: ${swap_bytes}

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
  - git checkout ${discourse_docker_version}
  - mv /root/app.yml containers/
  - ./launcher bootstrap app
  - ./launcher start app

power_state:
  mode: reboot
  message: "Provisioning complete after $UPTIME seconds, rebooting..."