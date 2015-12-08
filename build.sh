#!/bin/sh

case $1 in
	rawhide)
		os=rawhide
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

virt-builder $dist -o $os.qcow2 --format qcow2 --root-password password:$os --update $options --size 10G $run
virt-install --name $os --ram 1024 --disk path=$os.qcow2,format=qcow2,cache=writeback --nographics --os-variant $osvariant --import
