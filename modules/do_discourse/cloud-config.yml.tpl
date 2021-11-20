#cloud-config

package_update: true
package_upgrade: true

packages:
  - docker.io
  - nginx

runcmd:
  - git clone https://github.com/discourse/discourse_docker.git /var/discourse

final_message: "System boot took $UPTIME seconds"