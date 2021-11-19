#cloud-config

package_update: true
package_upgrade: true

packages:
  - docker.io
  - nginx

runcmd:
  - echo hello

final_message: "System boot took $UPTIME seconds"