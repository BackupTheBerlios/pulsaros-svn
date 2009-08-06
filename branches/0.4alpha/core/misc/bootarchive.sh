#!/bin/sh
# Description: 	bootarchive.sh - Create pulsaros bootarchive
# Version:		0.4
#===========================================================

# Variables
PROGNAME=$0
BASEDIR=$1
MINIROOTDIR=$2
IMAGE=$3
ARCH=$4

# Syntax check
. ../include/utils.sh
SYNTAX="${PROGNAME} base_directory minroot_directory miniroot_image"
[ $# != 4 ] && arg_error "wrong number of arguments" "${SYNTAX}"
[ ! -d "${BASEDIR}" ] && arg_error "${BASEDIR} directory does not exist" "${SYNTAX}"
[ "${BASEDIR}" = "/" ] && arg_error "'/' not permitted as a base directory" "${SYNTAX}"
[ ! -d "${MINIROOTDIR}" ] && arg_error "${MINIROOTDIR} directory does not exist" "${SYNTAX}"
[ "${MINIROOTDIR}" = "/" ] && arg_error "'/' is definitely not a valid miniroot directory" "${SYNTAX}"

# Create pulsaros full archive 
msg_to_stderr "copy kernel to boot directory and fix ksh93"
if [ $ARCH = "x86" ]; then
	cp ${MINIROOTDIR}/platform/i86pc/kernel/unix ${BASEDIR}/boot/boot/platform/i86pc/kernel/
else
	cp ${MINIROOTDIR}/platform/i86pc/kernel/amd64/unix ${BASEDIR}/boot/boot/platform/i86pc/kernel/amd64/
	ln -s ${MINIROOTDIR}/usr/bin/amd64/ksh93 ${MINIROOTDIR}/usr/bin/ksh93
fi
msg_to_stderr "creating full miniroot_archive"
if [ $ARCH = "x86" ]; then
	mkfile 130m ${BASEDIR}/boot/boot/${IMAGE}
else
	mkfile 135m ${BASEDIR}/boot/boot/${IMAGE}
fi
lofiadm -a ${BASEDIR}/boot/boot/${IMAGE} > /dev/null 2>&1
yes | newfs -m 0 /dev/rlofi/1 >/dev/null 2>&1
mount /dev/lofi/1 /pulsar_boot
cd ${MINIROOTDIR}
tar -cf /installer/tmp.tar .
cd /pulsar_boot
tar -xf /installer/tmp.tar
rm /installer/tmp.tar
cp -r ${BASEDIR}/platform/pulsarroot/bin /pulsar_boot/pulsarroot/
cp -r ${BASEDIR}/platform/pulsarroot/plugins /pulsar_boot/pulsarroot/
cp -r ${BASEDIR}/platform/pulsarroot/frontend /pulsar_boot/pulsarroot/
# delete svn directories
cd /pulsar_boot/pulsarroot
find . -name .svn -exec rm -rf {} \;
# create initial .version
if [ $ARCH = "x86" ]; then
	echo "0.4alpha_x86\t003" > /pulsar_boot/pulsarroot/bin/.version
else
	echo "0.4alpha_x64\t002" > /pulsar_boot/pulsarroot/bin/.version
	# change the ksh93 shell to 64-bit
	cat /pulsar_boot/pulsarroot/bin/changeconfig | sed "s,\/usr/\bin\/ksh93=,\/bin\/amd64\/ksh93,g" > /pulsar_boot/pulsarroot/bin/changeconfig
	cat /pulsar_boot/pulsarroot/bin/plugin | sed "s,\/usr/\bin\/ksh93=,\/bin\/amd64\/ksh93,g" > /pulsar_boot/pulsarroot/bin/plugin
	cat /pulsar_boot/pulsarroot/bin/restore | sed "s,\/usr/\bin\/ksh93=,\/bin\/amd64\/ksh93,g" > /pulsar_boot/pulsarroot/bin/restore
	cat /pulsar_boot/pulsarroot/bin/update | sed "s,\/usr/\bin\/ksh93=,\/bin\/amd64\/ksh93,g" > /pulsar_boot/pulsarroot/bin/update
	cat /pulsar_boot/pulsarroot/bin/setup/setup.sh | sed "s,\/usr/\bin\/ksh93=,\/bin\/amd64\/ksh93,g" > /pulsar_boot/pulsarroot/bin/setup/setup.sh	
fi
cd /
umount /pulsar_boot
lofiadm -d /dev/lofi/1
[ -f ${BASEDIR}/boot/boot/${IMAGE}.gz ] && rm ${BASEDIR}/boot/boot/${IMAGE}.gz 
gzip -9 ${BASEDIR}/boot/boot/${IMAGE}

# Archive usr directory for update usage
msg_to_stderr "cp usr directory for updates"
cd ${MINIROOTDIR}/usr
tar -cf ${BASEDIR}/boot/usr.tar .

# Create pulsaros update archive 
msg_to_stderr "creating update miniroot_archive"
if [ $ARCH = "x86" ]; then
	mkfile 46m ${BASEDIR}/boot/${IMAGE}_update
else
	mkfile 75m ${BASEDIR}/boot/${IMAGE}_update
fi
lofiadm -a ${BASEDIR}/boot/${IMAGE}_update > /dev/null 2>&1
yes | newfs -m 0 /dev/rlofi/1 >/dev/null 2>&1
mount /dev/lofi/1 /pulsar_boot
cd ${MINIROOTDIR} && rm -r usr/*
tar -cf /installer/tmp.tar .
cd /pulsar_boot
tar -xf /installer/tmp.tar
rm /installer/tmp.tar
cd /
umount /pulsar_boot
lofiadm -d /dev/lofi/1
[ -f ${BASEDIR}/boot/${IMAGE}_update.gz ] && rm ${BASEDIR}/boot/${IMAGE}_update.gz
gzip -9 ${BASEDIR}/boot/${IMAGE}_update

# create pulsar mini container
cd ${MINIROOTDIR} && rm -r usr lib sbin kernel platform
tar -cf ${BASEDIR}/boot/miniroot.tar .
cd /

# create menu entries for the grub boot loader
msg_to_stderr "creating grub/menu.lst"
echo "default 0" > ${BASEDIR}/boot/boot/grub/menu.lst
echo "timeout 10" >> ${BASEDIR}/boot/boot/grub/menu.lst
echo "title PulsarOS" >> ${BASEDIR}/boot/boot/grub/menu.lst
if [ $ARCH = "x86" ]; then
	echo "kernel /boot/platform/i86pc/kernel/unix -v" >> ${BASEDIR}/boot/boot/grub/menu.lst
else
	echo "kernel /boot/platform/i86pc/kernel/amd64/unix -v" >> ${BASEDIR}/boot/boot/grub/menu.lst
fi
echo "module /boot/${IMAGE}.gz" >> ${BASEDIR}/boot/boot/grub/menu.lst

exit 0
