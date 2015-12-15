# XXX: have a look here to boot up the vm if it's stuck at "loading initial ramdisk" https://unix.stackexchange.com/questions/203768/debian-8-kvm-guest-loading-initial-ramdisk
sed -i 's/jessie/testing/g' /etc/apt/sources.list
apt-get -y update && APT_LISTCHANGES_FRONTEND=none apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" dist-upgrade
apt-get -y autoremove && apt-get -y clean
apt-get -y install vim golang apt-transport-https
systemctl enable getty@ttyS0

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sh -c 'cat >/etc/apt/sources.list.d/docker.list <<-EOF
deb https://apt.dockerproject.org/repo debian-stretch main
EOF'
apt-get -y update && apt-get -y install docker-engine
systemctl enable docker

reboot
