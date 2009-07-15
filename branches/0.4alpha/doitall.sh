#!/bin/sh -x
# Copyright 2009 Thomas Brandstetter. All rights reserved.
# Description: 	doitall.sh - creates the pulsaros image and
# 		cleans up the framework directory
# Version:	0.3
#==========================================================

# Variables
HOME=`/usr/bin/pwd`
VERSION=$1
ARCH=$2

# Syntax check
[ $# != 2 ] && printf "Argument expected: doitall.sh 'version' 'arch' \n" && exit 1

# Pre cleanup
if [ -f $HOME/install_$ARCH.log ]; then
  rm $HOME/install_$ARCH.log
fi

# Build the pulsar os image
clear
printf "\n1. Step - Building the pulsar os $ARCH image\n"
cd core
ant makeimage_$ARCH >> $HOME/install_$ARCH.log 2>&1
cd ..

# Build the updater package
printf "2. Step - Build the updater package for pulsar $ARCH \n"
[ -f /installer/updates/latest_$ARCH.tar.gz ] && rm /installer/updates/latest_$ARCH.tar.gz
mv $HOME/core/boot/usr.tar /installer/updates/latest_$ARCH.tar
mv $HOME/core/boot/os_update.gz /installer/updates/os.gz
if [ $ARCH = "x86" ]; then
	cp $HOME/core/boot/boot/platform/i86pc/kernel/unix /installer/updates/
else
	cp $HOME/core/boot/boot/platform/i86pc/kernel/amd64/unix /installer/updates/
fi
cd /installer/updates
mkdir corebin && cp $HOME/core/platform/pulsarroot/bin/* corebin/
rm corebin/changes
tar -uf latest_$ARCH.tar os.gz unix corebin
gzip -9 latest_$ARCH.tar
rm -r os.gz unix corebin

# Create the install cd
echo "3. Step - Creating the pulsar installer $ARCH cd\n"
cd $HOME/core/boot
mkisofs -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -o /installer/images/pulsar_${VERSION}_$ARCH.iso $HOME/core/boot >> $HOME/install_$ARCH.log 2>&1
/usr/bin/usbgen /installer/images/pulsar_${VERSION}_$ARCH.iso /installer/images/pulsar_${VERSION}_$ARCH.usb /tmp 2>&1
echo "Creation of the pulsar x86 installer usb image ready"

# Post cleanup x86
rm $HOME/core/boot/boot/os.gz
if [ $ARCH = "x86" ]; then
	rm $HOME/core/boot/boot/platform/i86pc/kernel/unix
else
	rm $HOME/core/boot/boot/platform/i86pc/kernel/amd64/unix
fi
rm $HOME/core/boot/miniroot.tar
rm -r $HOME/core/miniroot
rm $HOME/core/packages.log
