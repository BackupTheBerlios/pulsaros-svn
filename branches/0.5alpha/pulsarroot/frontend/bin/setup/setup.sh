#!/bin/ash
# Copyright 2009 Thomas Brandstetter. All rights reserved.
# Description:	setup.sh - Setup script to install pulsaros to
#               disk/usbstick/cfcard....
# Version:      0.5
#=============================================================

# Variables
#
# ============================================================

trap "" 2 3
HOME=/pulsarroot/frontend/bin/setup
LOG=/pulsarroot/frontend/www/install_log.txt

# Private functions
#
# ============================================================

post_cleanup()
{
	[ `df -k|awk '/\/mnt$/ { print $6 }'|wc -l` = 1 ] && /bin/umount /mnt
	[ `losetup |wc -l` -gt 1 ] && losetup -d /dev/loop/0
	[ -f $LOG ] && rm $LOG
}

get_debug()
{
	# function to get information about your system - in case of problems!
	printf "Starting debug information logging\n" >> $LOG
	printf "==================================\n" >> $LOG
	lspci >> $LOG
	lsusb >> $LOG
	# end of debug
}
	

get_installer()
{
	if [ $mount = "none" ]; then
		if [ -f /proc/sys/dev/cdrom/info ]; then
			cdrom=`cat /proc/sys/dev/cdrom/info |grep "drive name"|awk '{ print $3 }'`
			mount /dev/${cdrom} /mnt
			if [ -f /mnt/.pulsarinstall ]; then
				printf "Installer Device: $cdrom\n" >> $LOG
				mount=$cdrom
			else
				umount /mnt
			fi
		else
			if [ `file /dev/${i}1 | grep -c x86` = 1 ]; then
				mount /dev/${i}1 /mnt
				if [ -f /mnt/.pulsarinstall ]; then
					printf "Installer Device: $i\n" >> $LOG
					mount=$i
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
	mount="none"
	# ===========================
	# cleanup everything before
	post_cleanup
	clear
	printf "begin\n"
	for i in `fdisk -l| grep Disk| grep -v partition | awk '{print $2}'|cut -d'/' -f3|cut -d':' -f1`; do
		get_installer $i
		size=` fdisk -l|grep Disk| grep -v partition | grep $i | awk '{print $3}'`
		model=`hdparm -i /dev/$i|grep Model|awk -F= '{ print $2$3 }'|cut -d',' -f1`
		# do not print out the pulsar installer
		if [ $mount != $i ]; then
			printf "Disk : $i Size: $size Model: $model \n" >> $LOG
			printf "$i $size $model \n"
		fi
	done
}

get_net()
{
	# Variables for this function
	number=0
	# ===========================
	for i in `ip link|grep -v link|grep -v lo|awk '{print $2}'|cut -d':' -f1`; do
		printf "Network Card: $i\n" >> $LOG
		printf "$i\n"
	done
}

rm_files()
{
	for i in `cat $HOME/rm.txt`; do
		rm -r /pulsarimage/$i
	done
}

install_os()
{
	# Variables for this function
	disk=$1
	nwcard=$2
	dhcp=$3
	hostname=$4
	ipaddr=$5
	netmask=$6
	gateway=$7
	nameserver=$8
	printf "Variables for installation: Disk: $1, Network Card: $2, DHCP: $3, Hostname: $4, IP Address: $5, Netmask: $6, Gateway: $7, Nameserver: $8\n" >> $LOG
	# ===========================
	# prepare choosen disk
	disk=/dev/${disk}
	fdisk ${disk} < $HOME/format.cmd >/dev/null 2>&1
	sleep 2
	if [ `fdisk -l | head -n 7| tail -n 1| grep -c '\*'` != "1" ]; then
		fdisk ${disk} < $HOME/activate.cmd >/dev/null 2>&1
		sleep 2
	fi
	mkfs.ext2 ${disk}1 >/dev/null 2>&1
	mkfs.ext2 ${disk}2 >/dev/null 2>&1
	check_dir "/boot"
	check_dir "/pulsarcore"
	#=============================
	# install mbr to disk
	dd if=/dev/zero of=${disk} bs=446 count=1
	dd if=/usr/share/syslinux/mbr.bin of=${disk}
	#=============================
	# install os to disk
    	mount ${disk}1 /boot
	mount ${disk}2 /pulsarcore
    	mkdir -p /boot/boot/extlinux
    	cp  /mnt/boot/isolinux/isolinux.cfg /boot/boot/extlinux/extlinux.conf
    	cp  /mnt/boot/isolinux/initrd.bz2 /boot/boot/extlinux/initrd.bz2
    	cp  /mnt/boot/isolinux/bzImage /boot/boot/extlinux/bzImage
    	extlinux -i /boot/boot/extlinux
    	touch /boot/.installed
    	#======================================================================================
    	# open os image
    	check_dir "/pulsarimage"
    	bunzip2 /boot/boot/extlinux/initrd.bz2
    	mount -o loop /boot/boot/extlinux/initrd /pulsarimage > /dev/null 2>&1
    	#======================================================================================
    	# create customized filesystem entries
	cp $HOME/fstab $HOME/fstab.work
	echo "${disk}2 /pulsarroot ext2 rw 0 1" >> $HOME/fstab.work
	#======================================================================================
	# configure base system
	cp $HOME/fstab.work /pulsarimage/etc/fstab
	rm $HOME/fstab.work
	mkdir /pulsarimage/pulsarroot
	# copy frontend to system
	cp -rp /pulsarroot/* /pulsarcore/
	cp $HOME/routes.php /pulsarcore/frontend/www/system/application/config/
	# remove unecessary files
	rm -r /pulsarimage/pulsarroot/*
	rm_files
	#======================================================================================
	# configure network
	if [ "$dhcp" = "n" ]; then
		cp $HOME/interfaces /pulsarcore/configs/network/interfaces
		echo "auto $nwcard" >> /pulsarcore/configs/network/interfaces
		echo "iface $nwcard inet static" >> /pulsarcore/configs/network/interfaces 
		echo "address $ipaddr" >> /pulsarcore/configs/network/interfaces 
		echo "netmask $netmask" >> /pulsarcore/configs/network/interfaces
		echo "gateway $gateway" >> /pulsarcore/configs/network/interfaces
		echo $hostname > /pulsarimage/etc/hostname
		echo "nameserver ${nameserver}" > /pulsarimage/etc/resolv.conf
		echo "static network configured" >> $LOG
	elif [ "$dhcp" = "y" ]; then
		echo $hostname > /pulsarimage/etc/hostname
		echo "dhcp configured" >> $LOG
	fi
	# cp dropbear keys to system
	cp -rp /pulsarroot/configs/dropbear /pulsarcore/configs/
	#======================================================================================
	# finish 
	umount /pulsarimage
	bzip2 -9  /boot/boot/extlinux/initrd
	losetup -d /dev/loop0	
	umount /boot
	umount /pulsarcore
	printf "PulsarOS successfully installed" >> $LOG
	#======================================================================================
}

# Main program starts here
# Options for the webbased installer

case $1 in
	get_disks)
		get_disks
		exit 0
		;;
	get_net)
		get_net
		exit 0
		;;
	install_os)
		get_debug
		install_os $2 $3 $4 $5 $6 $7 $8 $9 $10
		exit 0
		;;	
	*)
		printf "Not an api function!"
		;;
esac

exit 0
