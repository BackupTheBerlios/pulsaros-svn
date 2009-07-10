#!/bin/sh
# Copyright 2009 Thomas Brandstetter. All rights reserved.
# Description: 	doitall.sh - creates the pulsaros image and
# 		cleans up the framework directory
# Version:	0.3
#==========================================================

# Variables
rdisk=/dev/rdsk/${1}
disk=/dev/dsk/${1}
HOME=`/usr/bin/pwd`
VERSION=$1

# Syntax check
[ $# != 1 ] && printf "Argument expected: doitall.sh 'version'\n" && exit 1

# Pre cleanup
if [ -f $HOME/install.log ]; then
  rm $HOME/install.log
fi

# Build the pulsar os image
clear
printf "\n1. Step - Building the pulsar os image\n"
cd core
ant makeimage >> $HOME/install.log 2>&1
cd ..

# Build the updater package
printf "2. Step - Build the updater package for pulsar\n"
[ -f /installer/updates/latest.tar.gz ] && rm /installer/updates/latest.tar.gz
mv $HOME/core/boot/usr.tar /installer/updates/latest.tar
mv $HOME/core/boot/os_update.gz /installer/updates/os.gz 
cp $HOME/core/boot/boot/platform/i86pc/kernel/unix /installer/updates/
cd /installer/updates
mkdir corebin && cp $HOME/core/platform/pulsarroot/bin/* corebin/
rm corebin/changes
tar -uf latest.tar os.gz unix corebin
gzip -9 latest.tar
rm -r os.gz unix corebin

# Create the install cd
echo "3. Step - Creating the pulsar installer cd\n"
cd $HOME/core/boot
mkisofs -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -o /installer/images/pulsar_${VERSION}.iso $HOME/core/boot >> $HOME/install.log 2>&1
/usr/bin/usbgen /installer/images/pulsar_${VERSION}.iso /installer/images/pulsar_${VERSION}.usb /tmp 2>&1
echo "Creation of the pulsar installer usb image ready"

# Post cleanup
rm $HOME/core/boot/boot/os.gz
rm $HOME/core/boot/boot/platform/i86pc/kernel/unix
rm $HOME/core/boot/miniroot.tar
rm -r $HOME/core/miniroot
rm $HOME/core/packages.log
