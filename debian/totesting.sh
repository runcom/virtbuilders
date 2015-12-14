sed -i 's/jessie/testing/g' /etc/apt/sources.list
DEBIAN_FRONTEND=noninteractive apt-get -y update && apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" dist-upgrade
apt-get autoremove && apt-get clean
apt-get -y install vim
# hack from https://unix.stackexchange.com/questions/203768/debian-8-kvm-guest-loading-initial-ramdisk
systemctl enable getty@ttyS0
reboot
