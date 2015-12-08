dnf install -y fedora-repos-rawhide
dnf config-manager --set-disabled fedora updates updates-testing
dnf config-manager --set-enabled rawhide
dnf --releasever=rawhide distro-sync -y --nogpgcheck
reboot
