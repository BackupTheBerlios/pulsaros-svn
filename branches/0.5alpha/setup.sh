#!/bin/sh
# Copyright 2009 Thomas Brandstetter. All rights reserved.
# Description: 	setup.sh - finalize the pulsaros image
# Version:	0.5
#==========================================================

# Variables

HOME=/buildroot
ARCH=$1
BOOT_HOME=$HOME/boot_$ARCH/boot/isolinux
MOUNT_CD=$HOME/mount/cdrom
MOUNT_PULSAR=$HOME/mount/pulsar
SETUP_HOME=$HOME/0.5alpha

# Syntax check
[ $# != 1 ] && printf "Argument expected: setup.sh 'arch' \n" && exit 1

# Pre cleanup
#if [ -f $HOME/install_$ARCH.log ]; then
#  rm $HOME/install_$ARCH.log
#fi

# Build the pulsar os image
# Functions

make_pulsar ()
{
	echo "Create cdrom image"
	if [ -f $BOOT_HOME/initrd.bz2 ]; then
		rm $BOOT_HOME/initrd*
	fi
	cd $SETUP_HOME
	cp configs/buildroot_$ARCH.config $HOME/build_$ARCH/.config
	cd $HOME/build_$ARCH && make
}	

mount_images ()
{
	echo "Mount images"
	sudo mount -o loop $BOOT_HOME/initrd $MOUNT_CD
	
}

unmount_images ()
{
	echo "Unmount images"
	cd $HOME
	sudo umount $MOUNT_CD
	bzip2 $BOOT_HOME/initrd
}

rm_files ()
{
	echo "Remove files"
	#sudo rm $MOUNT_HOME/boot/bzImage
}

copy_startupfiles ()
{
        echo "Copy startupfiles"
        cd $SETUP_HOME/startupscripts/
        sudo cp *  $MOUNT_CD/etc/init.d/
}

copy_configs ()
{
        echo "Copy configs"
        cd $SETUP_HOME/configs/system/
        sudo cp -r *  $MOUNT_CD/etc/
	cd $MOUNT_CD/etc
	# do nasty stuff with etc links
	sudo rm httpd.conf
	sudo rm -r monit*
	sudo rm -r default
	sudo rm -r network
	sudo rm -r dropbear
	sudo rm init.d/S10udev init.d/S20urandom init.d/S40network init.d/S49ntp init.d/S50dropbear init.d/S91smb
}

copy_frontend ()
{
        echo "Copy frontend"
        cd $SETUP_HOME
        sudo cp -r pulsarroot  $MOUNT_CD/
}

make_image ()
{
	echo "Make image"
	cd $HOME
	mkisofs -r -J -pad -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -no-emul-boot -boot-info-table -boot-load-size 4 -o /buildroot/images/pulsaros_$ARCH.iso boot_$ARCH
}

# Main script
make_pulsar
mount_images
copy_startupfiles
copy_frontend
copy_configs
rm_files
unmount_images
make_image
