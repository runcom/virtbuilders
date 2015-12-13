dnf install -y fedora-repos-rawhide
dnf config-manager --set-disabled fedora updates updates-testing
dnf config-manager --set-enabled rawhide
dnf --releasever=rawhide distro-sync -y --nogpgcheck

# installing stuff I need while hacking on docker
dnf update -y
dnf install -y vim-enhanced docker golang git glibc-static systemd-devel device-mapper-devel audit-libs-devel
systemctl enable docker
git clone https://github.com/runcom/docker /root/docker
cd /root/docker \
	&& git remote add upstream https://github.com/docker/docker \
	&& git remote add projectatomic https://github.com/projectatomic/docker \
	&& git fetch upstream -a --tags \
	&& git fetch projectatomic -a --tags
sh -c 'cat >/root/build-docker.sh <<-EOF
#!/bin/sh

if [ ! -e MAINTAINERS ]; then
	echo "please run this script relative to the docker git directory, e.g. cd docker && ../build-docker.sh"
	exit
fi

AUTO_GOPATH=1 BUILDFLAGS="-race" DOCKER_BUILDTAGS="experimental selinux journald exclude_graphdriver_btrfs exclude_graphdriver_zfs exclude_graphdriver_aufs" ./hack/make.sh dynbinary
EOF'
chmod +x /root/build-docker.sh

reboot
