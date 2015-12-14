# XXX: have a look here to boot up the vm if it's stuck at "loading initial ramdisk" https://unix.stackexchange.com/questions/203768/debian-8-kvm-guest-loading-initial-ramdisk
sed -i 's/jessie/testing/g' /etc/apt/sources.list
apt-get -y update && APT_LISTCHANGES_FRONTEND=none apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" dist-upgrade
apt-get -y autoremove && apt-get -y clean
apt-get -y install vim
systemctl enable getty@ttyS0
reboot
