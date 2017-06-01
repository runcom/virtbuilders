#!/bin/sh

# using sudo so I can use virbr0 for nat...the default network does not work with unprivileged users :(

# EXAMPLE:
#
# OSNAME=rhel73-1 ./build.sh rhel $HOME/qcows/rhel-guest-image-7.3-35.x86_64.qcow2
# OSNAME=rawhide-customk0 KERNEL=/home/amurdaca/koding/linux/arch/x86/boot/bzImage ./build.sh fedora $HOME/qcows/Fedora-Cloud-Base-Rawhide-20161126.n.0.x86_64.qcow2


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
kernel=${KERNEL:-""}
os=$1
version=$2
root_password=${PASSWORD:-$1}

case $os in
	ubuntu1604|rhel72|rhel73|rhel|centos|"rhel-atomic"|"centos-atomic"|"fedora-atomic"|fedora)
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
			ubuntu1604)
				osvariant="--os-variant ubuntu16.04"
				;;
			fedora)
				osvariant="--os-variant fedora"
				;;
			centos)
				osvariant="--os-variant centos7.0"
				;;
			rhel72)
				osvariant="--os-variant rhel7.2"
				;;
			rhel73)
				osvariant="--os-variant rhel7.3"
				;;
			"rhel-atomic"|"centos-atomic")
				osvariant="--os-variant rhel-atomic-7.2"
				;;
			"fedora-atomic")
				# TODO: fixme
				osvariant="--os-variant rhel-atomic-7.2"
				;;
		esac
		if [ ! -z $KERNEL ]; then
			custom_kernel=( --boot kernel=$KERNEL,kernel_args='root=/dev/sda1 ro no_timer_check console=tty1 console=tty0 console=ttyS0,115200n8 console=ttS1 ds=nocloud-net' )
		fi
		./gen_iso.sh $1 $name
		sudo qemu-img resize ./$name/$name.qcow2 +20G
		sudo virt-install --name $name --ram 4096 --vcpus=2 --disk path=./$name/$name.qcow2,format=qcow2,cache=writeback --nographics $osvariant --disk path=./$name/init.iso,device=cdrom,readonly=on "${custom_kernel[@]}" --import --noreboot
		# add disk, default 4G, remember to format it :)
		qemu-img create -f raw "./$name/$name.disk" 4G
		sudo virsh attach-disk $name --source "$(pwd)/$name/$name.disk" --target vdb --persistent
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
