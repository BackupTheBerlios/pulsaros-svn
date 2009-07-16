#!/usr/bin/sh
# Copyright 2009 Thomas Brandstetter. All rights reserved.
# Description:	setup.sh - Setup script to install pulsaros to
#               disk/usbstick/cfcard....
# Version:      0.4
#=============================================================

# Variables
#
# ============================================================

trap "" 2 3
HOME=/pulsarroot/bin/setup

# Private functions
#
# ============================================================

post_cleanup()
{
	[ `df -k|awk '/\/mnt$/ { print $6 }'|wc -l` = 1 ] && /usr/sbin/umount /mnt
	[ `df -k|awk '/\/coreboot$/ { print $6 }'|wc -l` = 1 ] && /usr/sbin/umount /coreboot
	[ `lofiadm |wc -l` -gt 1 ] && lofiadm -d /dev/lofi/1
	[ -f /tmp/os ] && rm /tmp/os
	[ -f /tmp/os.gz ] && rm /tmp/os.gz
}

get_installer()
{
	if [ $mount = 0 ]; then
		if [ `iostat -Enx $i | egrep -ci "DVD|CD"` = 1 ]; then
			mount -F hsfs /dev/dsk/${i}s0 /mnt
			if [ -f /mnt/.pulsarinstall ]; then
				mount=1
			else
				umount /mnt
			fi
		else
			if [ `fstyp /dev/rdsk/${i}s0 2>/dev/null| grep -c ufs` = 1 ]; then
				mount /dev/dsk/${i}s0 /mnt
				if [ -f /mnt/.pulsarinstall ]; then
					mount=1
				else
					umount /mnt
				fi
			fi
		fi
	fi
}

check_dir()
{
	[ ! -d ${1} ] && mkdir ${1}
}

# Functions for the webbased installer
# 
# ============================================================

get_disks()
{
	# Variables for this function
	number=0
	mount=0
	# ===========================
	# cleanup everything before
	post_cleanup
	devfsadm >/dev/null 2>&1
	clear
	for i in `iostat -xn | awk '{print $11}' | egrep \^c`; do
		get_installer $i
		if [ `iostat -En $i | grep -c Model` = 1 ]; then
			size=`iostat -En $i | awk '/Size/ {print $9}'`
		else
			size=`iostat -En $i | awk '/Size/ {print $2}'`
		fi
		# do not print out the pulsar installer
		if [ $mount = 0 ]; then
			printf "$i $size\n"
		fi
	done
}

install_os()
{
	# Variables for this function
	disk=$1
	# ===========================
	# prepare choosen disk
	rdisk=/dev/rdsk/${disk}
	disk=/dev/dsk/${disk}
	fdisk -B ${rdisk}p0 >/dev/null 2>&1
	format -f $HOME/format.cmd ${rdisk}s2 >/dev/null 2>&1
	echo "y" | newfs ${rdisk}s0 >/dev/null 2>&1
	echo "y" | newfs ${rdisk}s1 >/dev/null 2>&1
	check_dir "/coreboot"
	# install os to disk
    mount ${disk}s0 /coreboot
    cp -rp /pulsarroot/bin /pulsarroot/plugins /pulsarroot/frontend /coreboot/
    mkdir /coreboot/boot
    cp -rp /mnt/boot/grub /mnt/boot/platform /coreboot/boot/
    # create os image
    check_dir "/pulsarimage"
    if [ `isainfo -b` = 64 ]; then
    	mkfile 80m /coreboot/boot/os
    else
    	mkfile 55m /coreboot/boot/os
    fi
    lofiadm -a /coreboot/boot/os > /dev/null 2>&1
    echo "y" | newfs -m 0 /dev/rlofi/1 >/dev/null 2>&1
    mount /dev/lofi/1 /pulsarimage
    cd /pulsarimage && tar -xpf /mnt/miniroot.tar .
    cd /; tar cf - lib sbin kernel platform | ( cd /pulsarimage; tar xpf - )
    mkdir /pulsarimage/usr
    check_dir "/pulsar_usr"
    mount ${disk}s1 /pulsar_usr
    cd /usr; tar cf - . | ( cd /pulsar_usr; tar xpf - )
    # install grub on disk
    echo "y" | installgrub -m /coreboot/boot/grub/stage1 /coreboot/boot/grub/stage2 ${rdisk}s0 >/dev/null 2>&1
    umount /pulsar_usr && umount /pulsarimage && umount /mnt
    lofiadm -d /dev/lofi/1
    touch /coreboot/.installed
    # create customized filesystem entries
	cp $HOME/vfstab $HOME/vfstab.work
	echo "${disk}s1 ${disk}s1 /usr ufs - no nologging" >> $HOME/vfstab.work
	echo "${disk}s0 ${disk}s0 /pulsarroot ufs - yes nologging" >> $HOME/vfstab.work
	printf "os installed"
}

get_net()
{
	# Variables for this function
	number=0
	# ===========================
	for i in `dladm show-phys | grep -v LINK | awk '{print $1}'`; do
		printf "$i\n"
	done
}

configure_os()
{
	# Variables for this function
	nwcard=$1
	dhcp=$2
	hostname=$3
	ipaddr=$4
	netmask=$5
	gateway=$6
	nameserver=$7
	# ===========================
	if [ ! -f /coreboot/.installed ]; then
		printf "pulsarnotinstalled"
		post_cleanup
		exit 1
	fi
	# mount the boot image for changes
	lofiadm -a /coreboot/boot/os > /dev/null 2>&1
	mount /dev/lofi/1 /mnt
	# configure base system
	cp $HOME/vfstab.work /mnt/etc/vfstab
	rm $HOME/vfstab.work
	cp $HOME/.profile /mnt/root/
	cp $HOME/profile /mnt/etc/
	cp $HOME/routes.php /coreboot/frontend/www/system/application/config/
	# configure network
	if [ "$dhcp" = "n" ]; then
		echo "$ipaddr $hostname" >> /mnt/etc/hosts
		echo $gateway > /mnt/etc/defaultrouter
		echo $hostname > /mnt/etc/hostname.${nwcard}
		echo $hostname > /mnt/etc/nodename
		echo "nameserver ${nameserver}" > /mnt/etc/resolv.conf
		cp $HOME/nsswitch.conf /mnt/etc/nsswitch.conf
		# disable nwam service
		SVCCFG_DTD=/usr/share/lib/xml/dtd/service_bundle.dtd.1
		SVCCFG_REPOSITORY=/mnt/etc/svc/repository.db	
		SVCCFG=/usr/sbin/svccfg
		export SVCCFG_DTD SVCCFG_REPOSITORY SVCCFG
		${SVCCFG} import /var/svc/manifest/milestone/sysconfig.xml
		${SVCCFG} -s network/physical:nwam setprop general/enabled=false
	elif [ "$dhcp" = "y" ]; then
		[ -f dhcp.* ] && rm /mnt/etc/dhcp.*
		echo "" > /mnt/etc/dhcp.${nwcard}
		[ -f /mnt/etc/hostname.* ] && rm /mnt/etc/hostname.*
		echo "" > /mnt/etc/hostname.${nwcard}
		echo $hostname > /mnt/etc/nodename
		cp $HOME/nsswitch.conf /mnt/etc/nsswitch.conf
	fi
	sleep 1
	umount /mnt
	lofiadm -d /coreboot/boot/os
	gzip -9 /coreboot/boot/os
	umount /coreboot
	printf "os configured"
}

# Main program starts here
# Options for the webbased installer

case $1 in
	get_disks)
		get_disks
		exit 0
		;;
	install_os)
		install_os $2
		exit 0
		;;	
	get_net)
		get_net
		exit 0
		;;
	configure_os)
		configure_os $2 $3 $4 $5 $6 $7 $8 $9
		exit 0
		;;
	*)
		printf "Not an api function!"
		;;
esac

exit 0