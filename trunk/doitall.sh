#!/bin/sh
# variables
rdisk=/dev/rdsk/${1}
disk=/dev/dsk/${1}

#cleanup
rm /installer/install.log

# Build the pulsar os image
echo "\n\n1. Step - Building the pulsar os image \n\n"
cd core
ant makeimage >>/installer/install.log 2>&1
cd ..
# Tar the pulsar os image
cp /installer/core/miniroot/platform/i86pc/kernel/unix /installer/core/stage2/boot/platform/i86pc/kernel/unix
cp -r /installer/core/boot /installer/core/stage2/
cd /installer/core/stage2
if [ -f /installer/core/stage2/pulsar_core.tar ]; then
  rm pulsar_core.tar
fi 
tar -cf pulsar_core.tar applications bin boot
# move it to the installer root
mv /installer/core/stage2/pulsar_core.tar /installer/installer/stage2/

# Build the updater package
echo "1.1. Step - Build the updater package for pulsar \n\n"
if [ -f /installer/updates/latest.tar.gz ]; then
  rm /installer/updates/latest.tar.gz
fi
cp /installer/installer/stage2/usr.tar /installer/updates/latest.tar
cp /installer/core/stage2/boot/os.gz /installer/updates/ 
cp /installer/core/stage2/boot/platform/i86pc/kernel/unix /installer/updates/
cd /installer/updates
tar -uf latest.tar os.gz unix
gzip -9 latest.tar
rm os.gz unix

# Build the pulsar installer image
echo "2. Step - Building the pulsar installer image\n\n"
cd /installer/installer
ant makeimage >>/installer/install.log 2>&1
cp /installer/installer/miniroot/platform/i86pc/kernel/unix /installer/installer/stage2/boot/platform/i86pc/kernel/unix
cp boot/opensolaris.gz stage2/boot/
cp -r boot/grub stage2/boot/
touch stage2/.pulsaros

# Create the install cd
echo "3. Step - Creating the pulsar installer cd\n\n"
cd /
mkisofs -R -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -o /installer/pulsar_v1.iso /installer/installer/stage2 >>/installer/install.log 2>&1
echo "Creation of the pulsar installer cd ready"
