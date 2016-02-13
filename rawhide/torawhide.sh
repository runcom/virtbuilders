dnf install -y fedora-repos-rawhide
dnf config-manager --set-disabled fedora updates updates-testing
dnf config-manager --set-enabled rawhide
dnf --releasever=rawhide distro-sync -y --nogpgcheck
dnf update -y
dnf install -y vim-enhanced git
sh -c 'cat >/etc/yum.repos.d/koji.repo <<-EOF
[koji]
name=Koji Repository
baseurl=http://kojipkgs.fedoraproject.org/repos/rawhide/latest/\$basearch/
enabled=0
gpgcheck=0
EOF'
reboot
