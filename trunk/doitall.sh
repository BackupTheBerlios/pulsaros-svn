#!/bin/sh
# variables
rdisk=/dev/rdsk/${1}
disk=/dev/dsk/${1}
HOME=/installer/trunk

#cleanup
if [ -f $HOME/install.log ]; then
  rm $HOME/install.log
fi

# Build the pulsar os image
echo "\n\n1. Step - Building the pulsar os image \n\n"
cd core
ant makeimage >> $HOME/install.log 2>&1
cd ..
# Tar the pulsar os image
cp $HOME/core/miniroot/platform/i86pc/kernel/unix $HOME/core/boot/boot/platform/i86pc/kernel/unix
#cp -r $HOME/core/boot $HOME/core/stage2/

# Build the updater package
echo "1.1. Step - Build the updater package for pulsar \n\n"
if [ -f /installer/updates/latest.tar.gz ]; then
  rm /installer/updates/latest.tar.gz
fi
mv $HOME/core/boot/usr.tar /installer/updates/latest.tar
# needs to be done for the updater script for existing installations
cd /installer/updates/usr
tar -xf /installer/updates/latest.tar ./bin/mv ./bin/cp ./bin/rm ./bin/cd ./bin/gzip ./bin/tar 
mv $HOME/core/boot/os_update.gz /installer/updates/os.gz 
cp $HOME/core/boot/boot/platform/i86pc/kernel/unix /installer/updates/
cd /installer/updates
tar -uf latest.tar os.gz unix
gzip -9 latest.tar
rm os.gz unix
if [ -f /installer/updates/latest_minibin.tar.gz ]; then
  rm /installer/updates/latest_minibin.tar.gz
fi
tar -cf latest_minibin.tar usr
gzip -9 latest_minibin.tar
if [ -f /installer/updates/corebin.tar.gz ]; then
  rm /installer/updates/corebin.tar.gz
fi
cp -r $HOME/core/platform/pulsarroot/bin .
tar -cf corebin.tar bin
gzip -9 corebin.tar
rm -r bin

# Create the install cd
echo "3. Step - Creating the pulsar installer cd\n\n"
cd /
mkisofs -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -o /installer/images/pulsar_v1.iso $HOME/core/boot >> $HOME/install.log 2>&1
/installer/distro_constructor/tools/usbgen /installer/images/pulsar_v1.iso /installer/images/pulsar_v1.usb /tmp 2>&1
echo "Creation of the pulsar installer usb image ready"

# cleanup
rm $HOME/core/boot/boot/os.gz
rm $HOME/core/boot/miniroot.tar
rm -r $HOME/core/miniroot
rm $HOME/core/packages.log
