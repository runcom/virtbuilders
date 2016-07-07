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

name=${OSNAME:-$1}
os=$1
version=$2
root_password=${PASSWORD:-$1}

case $os in
	ubuntu)
		size=${SIZE:-32G}
		is_available $name
		check_root $name
		ver=${UBUNTUVER:-14.04}
		dist="ubuntu-$ver"
		# TODO: ubuntu16.04 doesn't exist into osinfo-query os for instance and doesn't start uff
		if [ "$ver" != "14.04" ]; then
			ver="15.10"
		fi
		osvariant="ubuntu$ver"
		;;
	fedora)
		case $version in
			23)
				size=${SIZE:-32G}
				is_available $name
				check_root $name
				dist="fedora-23"
				# using fedora22 as os-variant becuse virt-install ins't updatd yet probably and errors out
				run="$RUN --run basic_fedora.sh"
				osvariant="fedora22"
				options="$OPTS --selinux-relabel"
				;;
			rawhide)
				size=${SIZE:-32G}
				is_available $name
				check_root $name
				dist="fedora-23"
				# using fedora22 as os-variant becuse virt-install ins't updated yet probably and errors out
				osvariant="fedora22"
				run="$RUN --run basic_fedora.sh"
				run="$run --run rawhide/torawhide.sh"
				if [ -n "$STUFF" ]; then
					run="$run --run rawhide/stuff.sh"
				fi
				options="$OPTS --selinux-relabel"
				;;
			*)
				echo "version not supported"
				exit
				;;
		esac
		;;
	rhel|"rhel-atomic"|"centos-atomic"|"fedora-atomic")
		path=$2
		if [ -z $path ]; then
			echo "please provide a path to a qcow2 image"
			exit
		fi
		is_available $name
		check_root $name
		cp $path ./$name.qcow2
		case $os in
			rhel)
				osvariant="rhel7.2"
				;;
			"rhel-atomic"|"centos-atomic")
				osvariant="rhel-atomic-7.1"
				;;
			"fedora-atomic")
				# TODO: fixme
				osvariant="rhel-atomic-7.1"
				;;
		esac
		./gen_iso.sh $1
		sudo virt-install --name $name --ram 2048 --vcpus=2 --disk path=./$name.qcow2,format=qcow2,cache=writeback --nographics --os-variant $osvariant --disk path=init.iso,device=cdrom,readonly=on --import
		exit
		;;
	*)
		echo "os not supported"
		exit
		;;
esac

# libguestfs-xfs.x86_64 is needed for --size on my f23
sudo virt-builder $dist -o $name.qcow2 --format qcow2 --root-password password:$root_password $options --size $size $run --hostname $name

sudo virt-install --name $name --ram 2048 --vcpus=2 --disk path=$name.qcow2,format=qcow2,cache=writeback --nographics --os-variant $osvariant --import

# subscribe:
# subscription-manager register --username amurdaca@redhat.com --auto-attach
# enable for docker:
# subscription-manager repos --enable rhel-7-server-extras-rpms
# enable for golang:
# subscription-manager repos --enable=rhel-7-server-optional-rpms
# yum update
