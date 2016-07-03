#!/bin/sh

instanceid=${1:-rhel72}

sh -c 'cat >meta-data <<-EOF
  instance-id: '$instanceid'
  local-hostname: '$instanceid'.vm
EOF'

sh -c 'cat >user-data <<-EOF
  #cloud-config
  password: '$instanceid'
  ssh_pwauth: True
  chpasswd:
    expire: False
EOF'

genisoimage -output init.iso -volid cidata -joliet -rock user-data meta-data
