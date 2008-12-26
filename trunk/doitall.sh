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
cp $HOME/core/miniroot/platform/i86pc/kernel/unix $HOME/core/stage2/boot/platform/i86pc/kernel/unix
cp -r $HOME/core/boot $HOME/core/stage2/
cd $HOME/core/stage2
if [ -f $HOME/core/stage2/pulsar_core.tar ]; then
  rm pulsar_core.tar
fi 
tar -cf pulsar_core.tar applications bin boot
# move it to the installer root
mv $HOME/core/stage2/pulsar_core.tar $HOME/installer/stage2/

# Build the updater package
echo "1.1. Step - Build the updater package for pulsar \n\n"
if [ -f /installer/updates/latest.tar.gz ]; then
  rm /installer/updates/latest.tar.gz
fi
cp $HOME/installer/stage2/usr.tar /installer/updates/latest.tar
cp $HOME/core/stage2/boot/os.gz /installer/updates/ 
cp $HOME/core/stage2/boot/platform/i86pc/kernel/unix /installer/updates/
cd /installer/updates
tar -uf latest.tar os.gz unix
gzip -9 latest.tar
rm os.gz unix
if [ -f /installer/updates/latest_minibin.tar.gz ]; then
  rm /installer/updates/latest_minibin.tar.gz
fi
tar -cf latest_minibin.tar usr
gzip -9 latest_minibin.tar

# cleanup
rm $HOME/core/stage2/boot/os.gz
rm $HOME/core/boot/os.gz
rm -r $HOME/core/miniroot
rm $HOME/core/packages.log
rm $HOME/core/stage2/boot/platform/i86pc/kernel/unix


# Build the pulsar installer image
echo "2. Step - Building the pulsar installer image\n\n"
cd $HOME/installer
ant makeimage >> $HOME/install.log 2>&1
cp $HOME/installer/miniroot/platform/i86pc/kernel/unix $HOME/installer/stage2/boot/platform/i86pc/kernel/unix
cp boot/opensolaris.gz stage2/boot/
cp -r boot/grub stage2/boot/
touch stage2/.pulsaros

# Create the install cd
echo "3. Step - Creating the pulsar installer cd\n\n"
cd /
mkisofs -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -o /installer/images/pulsar_v1.iso $HOME/installer/stage2 >> $HOME/install.log 2>&1
echo "Creation of the pulsar installer cd image ready"
/installer/distro_constructor/tools/usbgen /installer/images/pulsar_v1.iso /installer/images/pulsar_v1.usb /tmp 2>&1
echo "Creation of the pulsar installer usb image ready"

# cleanup
rm $HOME/installer/boot/opensolaris.gz
rm $HOME/installer/stage2/pulsar_core.tar
rm $HOME/installer/stage2/usr.tar
rm $HOME/installer/stage2/boot/opensolaris.gz
rm -r $HOME/installer/miniroot
rm $HOME/installer/packages.log
rm $HOME/installer/stage2/boot/platfrom/i86pc/kernel/unix
