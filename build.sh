#!/bin/sh

# using sudo so I can use virbr0 for nat...the default network does not work with unprivileged users :(

is_available() {
	available=( $(sudo virsh list --all --name) )
	for i in "${available[@]}"
	do
	    if [ "$i" == "$1"  ] ; then
		    echo "domain $1 already imported, please destroy and undefine it first"
		    exit
	    fi
	done
}

check_root() {
	if [ -e ./$1.qcow2 ]; then
		echo "$1.qcow2 exists, please remove it"
		exit
	fi
}

case $1 in
	f23)
		name=${OSNAME:-f23}
		size=${SIZE:-32G}
		is_available $name
		check_root $name
		root_password=${PASSWORD:-f23}
		dist="fedora-23"
		# using fedora22 as os-variant becuse virt-install ins't updatd yet probably and errors out
		run="$RUN --run basic_fedora.sh"
		osvariant="fedora22"
		options="$OPTS --selinux-relabel"
		;;
	rawhide)
		name=${OSNAME:-rawhide}
		size=${SIZE:-32G}
		is_available $name
		check_root $name
		root_password=${PASSWORD:-rawhide}
		dist="fedora-23"
		# using fedora22 as os-variant becuse virt-install ins't updatd yet probably and errors out
		osvariant="fedora22"
		run="$RUN --run basic_fedora.sh"
		run="$run --run rawhide/torawhide.sh"
		if [ -n "$STUFF" ]; then
			run="$run --run rawhide/stuff.sh"
		fi
		options="$OPTS --selinux-relabel"
		;;
	debian)
		name=${OSNAME:-debian}
		size=${SIZE:-32G}
		is_available $name
		check_root $name
		root_password=${PASSWORD:-debian}
		dist="debian-8"
		osvariant="debian8"
		# can't run this cause debian isn't booting with a tty and everything is stuck...
		# running this manually then..
		#run="$RUN --run debian/totesting.sh"
		;;
	*)
		echo "os not supported"
		exit
		;;
esac

# libguestfs-xfs.x86_64 is needed for --size on my f23
sudo virt-builder $dist -o $name.qcow2 --format qcow2 --root-password password:$root_password $options --size $size $run --hostname $name

# is network=default really needed????? --network network=default
sudo virt-install --name $name --ram 2048 --vcpus=2 --disk path=$name.qcow2,format=qcow2,cache=writeback --nographics --os-variant $osvariant --import

# fedora atomic
# XXX: JUST BOOT INTO DEV MODE???
#
# $ cat - > meta-data <<"EOF"
#   instance-id: atomic-host001
#   local-hostname: atomic01.example.org
# $ cat - > user-data <<"EOF"
#   #cloud-config
#   password: atomic
#   ssh_pwauth: True
#   chpasswd: { expire: False  }
#
#   #ssh_authorized_keys:
#   #  - ssh-rsa ... foo@bar.baz (insert ~/.ssh/id_rsa.pub here)
#
# $ genisoimage -output init.iso -volid cidata -joliet -rock user-data meta-data
#
# $ virt-install --name fedora-atomic --ram 2048 --vcpus=2 --network bridge=virbr0 --disk path=Fedora-Cloud-Atomic-23-20151215.x86_64.qcow2,format=qcow2,cache=writeback --nographics --os-variant fedora22 --disk path=init.iso,device=cdrom,readonly=on --import

# RHEL atomic

# $ cat - > meta-data <<"EOF"
#   instance-id: atomic-host001
#   local-hostname: atomic01.example.org
# $ cat - > user-data <<"EOF"
#   #cloud-config
#   password: atomic
#   ssh_pwauth: True
#   chpasswd: { expire: False  }
#
#   #ssh_authorized_keys:
#   #  - ssh-rsa ... foo@bar.baz (insert ~/.ssh/id_rsa.pub here)

# virt-install --name rhel72-atomic --ram 2048 --vcpus=2 --network bridge=virbr0 --disk path=rhel-atomic-cloud-7.2-10.x86_64.qcow2,format=qcow2,cache=writeback --disk path=init.iso,device=cdrom,readonly=on --os-variant=rhel-atomic-7.0 --nographics --import
#
#
#

# RHEL

# $ cat - > meta-data <<"EOF"
#   instance-id: rhel-host001
#   local-hostname: rhel01.example.org
# $ cat - > user-data <<"EOF"
#   #cloud-config
#   password: rhel
#   ssh_pwauth: True
#   chpasswd: { expire: False  }
#
#   #ssh_authorized_keys:
#   #  - ssh-rsa ... foo@bar.baz (insert ~/.ssh/id_rsa.pub here)

# virt-install --name rhel72 --ram 2048 --vcpus=2 --network bridge=virbr0 --disk path=rhel-guest-image-7.2-20151102.0.x86_64.qcow2,format=qcow2,cache=writeback --disk path=init.iso,device=cdrom,readonly=on --os-variant=rhel7.0 --nographics --import

# enable extras for Docker!
#
# subscription-manager repos --enable rhel-7-server-extras-rpms
# yum update && yum install docker
