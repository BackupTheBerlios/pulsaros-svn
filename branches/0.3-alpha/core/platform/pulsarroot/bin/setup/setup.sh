#!/usr/bin/ksh93
# Copyright 2009 Thomas Brandstetter. All rights reserved.
# Description:	setup.sh - Setup script to install pulsaros to
#               disk/usbstick/cfcard....
# Version:      0.3
#=============================================================

# Variables
trap "" 2 3
HOME=/pulsarroot/bin/setup

# Functions
post_cleanup()
{
	[ `df -k|awk '/\/mnt$/ { print $6 }'|wc -l` == 1 ] && /usr/sbin/umount /mnt
	[ `lofiadm |wc -l` -gt 1 ] && lofiadm -d /dev/lofi/1
	[ -f /tmp/os ] && rm /tmp/os
	[ -f /tmp/os.gz ] && rm /tmp/os.gz
}

clear_it()
{
	# Variables for this function
	function=$1
	# ===========================
	read JUNK
	clear
	post_cleanup
	$function
}

check_input()
{
	# Variables for this function
	function=$2
	input=$4
	item=$3 
	blacklist="0.0.0.0 127.0.0.1"
	# ===========================
	if [ "$input" != "" ]; then
		case $1 in
			number)
				if [ `echo $input | grep -c [0-9]` = 0 ]; then
					printf "Only numbers are allowed! - Press Return to Continue... "
					clear_it $function
				elif [ $input -gt $item ]; then
					printf "Choice doesn't exist! - Press Return to Continue... "
					clear_it $function
				fi
			;;
			ip | netmask)
				result=`echo $input| awk -F"\." ' $1 < 256 && $2 < 256 && $3 < 256  && $4 < 256 '`
				for ban in $blacklist; do
					if [ "$ban" == "$input" ]; then
						printf "Wrong syntax! - Press return to continue..."
						clear_it $function
					fi
				done
				if [ -z $result ]; then
					printf "Wrong syntax! - Press return to continue..."
					clear_it $function
				fi
			;;
			hostname)
				if [ `echo $input | grep -c [a-zA-Z]` = 0 ]; then
					printf "Only alphabetic characters are allowed! - Press Return to Continue... "
					clear_it $function
				fi
			;;
			*)
				printf "Interface error! - Please inform the developers!"
			;;
		esac
	else
		printf "Choice doesn't exist! - Press return to continue..."
		clear_it $function
	fi
}

display_header()
{
	create_line full
	printf " #\t\t\tPulsar OS installer main menu\t\t\t#\n"
	create_line space
	create_line space
	printf " #\t\t\t1. Copy OS to harddisk\t\t\t\t#\n"
	create_line space
	printf " #\t\t\t2. Reboot system\t\t\t\t#\n"
	create_line space
	printf " #\t\t\t0. Exit to command line\t\t\t\t#\n"
	create_line space
	create_line full
}

main_menu()
{
	clear
	display_header
	printf "\nEnter option: "
	read OPT1
	case $OPT1 in
		1)
			copy_os;;
		2)
			clear; init 6;;
		0)
			clear; exit 0;;
		*)
			menu_error;;
	esac
}

get_installer()
{
	if [ $mount == 0 ]; then
		if [ `iostat -Enx $i | egrep -ci "DVD|CD"` == 1 ]; then
			mount -F hsfs /dev/dsk/${i}s0 /mnt
			if [ -f /mnt/.pulsarinstall ]; then
				mount=1
			else
				umount /mnt
			fi
		else
			if [ `fstyp /dev/rdsk/${i}s0 | grep -c ufs` == 1 ]; then
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

create_line()
{
	if [ $1 == "full" ]; then
		echo " ########################################################################"
	else
		printf " #\t\t\t\t\t\t\t\t\t#\n"
	fi
}

copy_os()
{
	# Variables for this function
	number=0
	mount=0
	# ===========================
	devfsadm
	clear
	create_line full
	printf " #\t\tChoose the disk to install the os\t\t\t#\n"
	create_line space
	for i in `iostat -xn | awk '{print $11}' | egrep \^c`; do
		number=`expr $number + 1`
		disk[$number]=$i
		get_installer $i
		if [ `iostat -En $i | grep -c Model` == 1 ]; then
			size=`iostat -En $i | awk '/Size/ {print $9}'`
		else
			size=`iostat -En $i | awk '/Size/ {print $2}'`
		fi
		# do not print out the pulsar installer
		if [ $mount == 0 ]; then
			create_line space
			printf " #\t\t$number.)\tDisk: $i\tSize: $size\t\t\t#\n"
		else 
			number=`expr $number - 1`
		fi
	done
	create_line space
	create_line space
	create_line full
	printf "\nEnter option: "
	read OPT1
	check_input number copy_os $number $OPT1
	printf "\nAll data on disk /dev/dsk/${disk[$OPT1]} will be destroyed - ready (y/n)"
	read OPT2
	if [ "$OPT2" == "n" ]; then
		clear_it main_menu
	elif [ "$OPT2" == "y" ]; then
		# prepare choosen disk
		printf "\n\t1. Prepare disk for installation\n"
		rdisk=/dev/rdsk/${disk[$OPT1]}
		disk=/dev/dsk/${disk[$OPT1]}
		fdisk -B ${rdisk}p0 >/dev/null 2>&1
		format -f $HOME/format.cmd ${rdisk}s2 >/dev/null 2>&1
		yes | newfs ${rdisk}s0 >/dev/null 2>&1
		yes | newfs ${rdisk}s1 >/dev/null 2>&1
		check_dir "/coreboot"
		# install os to disk
		printf "\t2. Install OS to disk (This takes some time - grab a coffee)\n"
		mount ${disk}s0 /coreboot
		cp -rp /pulsarroot/bin /pulsarroot/plugins /coreboot/
		mkdir /coreboot/boot
		cp -rp /mnt/boot/grub /mnt/boot/platform /coreboot/boot/
		# create os image
		check_dir "/pulsarimage"
		mkfile 55m /coreboot/boot/os
		lofiadm -a /coreboot/boot/os > /dev/null 2>&1
		yes | newfs -m 0 /dev/rlofi/1 >/dev/null 2>&1
		mount /dev/lofi/1 /pulsarimage
		cd /pulsarimage && tar -xpf /mnt/miniroot.tar .
		cd / && tar cf - lib sbin kernel platform | ( cd /pulsarimage && tar xpf - )
		mkdir /pulsarimage/usr
		check_dir "/pulsar_usr"
		mount ${disk}s1 /pulsar_usr
		cd /usr && tar cf - . | ( cd /pulsar_usr && tar xpf - )
		# install grub on disk
		printf "\t3. Make disk bootable\n"
		yes | installgrub -m /coreboot/boot/grub/stage1 /coreboot/boot/grub/stage2 ${rdisk}s0 >/dev/null 2>&1
		umount /pulsar_usr && umount /pulsarimage && umount /mnt
		lofiadm -d /dev/lofi/1
		touch /coreboot/.installed
		printf "\nPulsar OS installed! - Press return to continue..."
		read JUNK
		clear
		config_os
	else
		printf "Wrong syntax! Only (y/n) is allowed! - Press return to continue..."
		clear_it copy_os
	fi
}

config_os()
{
	# Variables for this function
	number=0
	# ===========================
	if [ ! -f /coreboot/.installed ]; then
		printf "Pulsar os not installed, please install the os first! - Press Return to Continue... "
		clear_it main_menu
	fi
	# mount the boot image for changes
	lofiadm -a /coreboot/boot/os > /dev/null 2>&1
	mount /dev/lofi/1 /mnt
	# create customized filesystem entries
	cp $HOME/vfstab $HOME/vfstab.work
	echo "${disk}s1 ${disk}s1 /usr ufs - no nologging" >> $HOME/vfstab.work
	echo "${disk}s0 ${disk}s0 /pulsarroot ufs - yes nologging" >> $HOME/vfstab.work
	cp $HOME/vfstab.work /mnt/etc/vfstab
	rm $HOME/vfstab.work
	cp $HOME/.profile /mnt/root/
	cp $HOME/profile /mnt/etc/
	clear
	# configure network
	create_line full
	printf " #\t\t\tPulsar OS network configuration ...\t\t#\n"
	create_line space
	printf " #\tSelect the interface you want to configure for pulsar os:\t#\n"
	create_line space
	for i in `dladm show-phys | tail -1 | awk '{print $1}'`; do
		number=`expr $number + 1`
		nwcard[$number]=$i
		printf " #\t\t\t$number.) Interface: $i\t\t\t\t#\n"
	done
	if [ "$i" = "" ]; then
		printf " #\t\t\t\tNo Interface found!\t\t\t#\n"
	else
		create_line space
		create_line full
		printf "\nEnter option: "
		read OPT1
		check_input number config_os $number $OPT1
		interface=$OPT1
		printf "Use DHCP to configure the interface? (y/n)"
		read OPT2
		if [ "$OPT2" == "n" ]; then
			printf "Enter IP address: "
			read OPT3
			check_input ip config_os "" $OPT3
			printf "Enter netmask: "
			read OPT4
			check_input netmask config_os "" $OPT4
			printf "Enter default gateway: "
			read OPT5
			check_input ip config_os "" $OPT5
			printf "Enter hostname: "
			read OPT6
			check_input hostname config_os "" $OPT6
			printf "Enter DNS server: "
			read OPT7
			check_input ip config_os "" $OPT7
			echo "$OPT3 $OPT6" >> /mnt/etc/hosts
			echo $OPT5 > /mnt/etc/defaultrouter
			echo $OPT6 > /mnt/etc/hostname.${nwcard[$OPT1]}
			echo $OPT6 > /mnt/etc/nodename
			echo "nameserver ${OPT7}" > /mnt/etc/resolv.conf
			cp $HOME/nsswitch.conf /mnt/etc/nsswitch.conf
		elif [ "$OPT2" == "y" ]; then
			printf "\nEnter hostname: "
			read OPT3
			[ -f dhcp.* ] && rm /mnt/etc/dhcp.*
			echo "" > /mnt/etc/dhcp.${nwcard[$OPT1]}
			[ -f /mnt/etc/hostname.* ] && rm /mnt/etc/hostname.*
			echo "" > /mnt/etc/hostname.${nwcard[$OPT1]}
			echo $OPT3 > /mnt/etc/nodename
			cp $HOME/nsswitch.conf /mnt/etc/nsswitch.conf
		else
			printf "Wrong syntax! Only (y/n) is allowed! - Press return to continue..."
			clear_it config_os
		fi
	fi
	umount /mnt
	lofiadm -d /coreboot/boot/os
	gzip -9 /coreboot/boot/os
	umount /coreboot
	printf "\nInstallation ready! Please eject your cdrom or usb stick after reboot!\n"
	printf "Do you really want to reboot the system now? (y/n)"
	read OPT1
	if [ "$OPT1" == "n" ]; then
		main_menu
	elif [ "$OPT1" == "y" ]; then
		/usr/sbin/init 6
	else
		printf "Wrong syntax! Only (y/n) is allowed! - Press return to continue..."
		main_menu
	fi
}

menu_error()
{
	printf "\nChoice doesn't exist! - Press return to continue..."
	clear_it main_menu
}

# Main program starts here

main_menu

exit 0
