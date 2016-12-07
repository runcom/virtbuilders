#!/bin/sh

# using sudo so I can use virbr0 for nat...the default network does not work with unprivileged users :(

# EXAMPLE:
#
# OSNAME=rhel73-1 ./build.sh rhel $HOME/qcows/rhel-guest-image-7.3-35.x86_64.qcow2

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
	if [ -e ./$1/$1.qcow2 ]; then
		echo "$1/$1.qcow2 exists, please remove it"
		exit
	fi
}

name=${OSNAME:-$1}
os=$1
version=$2
root_password=${PASSWORD:-$1}

case $os in
	rhel|rawhide|centos|"rhel-atomic"|"centos-atomic"|"fedora-atomic"|fedora)
		path=$2
		if [ -z $path ]; then
			echo "please provide a path to a qcow2 image"
			exit
		fi
		is_available $name
		check_root $name
		mkdir $name
		cp $path ./$name/$name.qcow2
		case $os in
			rawhide)
				osvariant="fedora22"
				;;
			fedora)
				osvariant="fedora22"
				;;
			rhel|centos)
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
		./gen_iso.sh $1 $name
		sudo virt-install --name $name --ram 2048 --vcpus=2 --disk path=./$name/$name.qcow2,format=qcow2,cache=writeback --nographics --os-variant $osvariant --disk path=./$name/init.iso,device=cdrom,readonly=on --import --noreboot
		# add disk, default 4G, remember to format it :)
	       # qemu-img create -f raw "./$name/$name.disk" 4G
		#sudo virsh attach-disk $name --source "$(pwd)/$name/$name.disk" --target vdb --persistent
	       # sudo virt-customize -a $(pwd)/$name/$name.qcow2 --hostname $name.vm
		# start it!
		sudo virsh start $name
		exit
		;;
	*)
		echo "os not supported"
		exit
		;;
esac

# libguestfs-xfs.x86_64 is needed for --size on my f23
#sudo virt-builder $dist -o $name.qcow2 --format qcow2 --root-password password:$root_password $options --size $size $run --hostname $name

#sudo virt-install --name $name --ram 2048 --vcpus=2 --disk path=$name.qcow2,format=qcow2,cache=writeback --nographics --os-variant $osvariant --import


# subscribe:
# subscription-manager register --username amurdaca@redhat.com --auto-attach
# enable for docker:
# subscription-manager repos --enable rhel-7-server-extras-rpms
# enable for golang:
# subscription-manager repos --enable=rhel-7-server-optional-rpms
# yum update
