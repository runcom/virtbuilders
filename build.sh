#!/bin/sh

case $1 in
	rawhide)
		name=${OSNAME:-rawhide}
		root_password=${PASSWORD:-rawhide}
		dist="fedora-23"
		# using fedora22 as os-variant becuse virt-install ins't updatd yet probably and errors out
		osvariant="fedora22"
		run="$RUN --run rawhide/torawhide.sh"
		options="$OPTS --selinux-relabel"
		;;
	*)
		echo "os not supported"
		exit
		;;
esac

virt-builder $dist -o $name.qcow2 --format qcow2 --root-password password:$root_password --update $options --size 10G $run
virt-install --name $name --ram 1024 --disk path=$name.qcow2,format=qcow2,cache=writeback --nographics --os-variant $osvariant --import
