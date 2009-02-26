#!/bin/sh
# Description: 	bootarchive.sh - Create pulsaros bootarchive
# Version:		0.3
#===========================================================

# Variables
PROGNAME=$0
BASEDIR=$1
MINIROOTDIR=$2
IMAGE=$3

# Syntax check
. ../include/utils.sh
SYNTAX="${PROGNAME} base_directory minroot_directory miniroot_image"
[ $# != 3 ] && arg_error "wrong number of arguments" "${SYNTAX}"
[ ! -d "${BASEDIR}" ] && arg_error "${BASEDIR} directory does not exist" "${SYNTAX}"
[ "${BASEDIR}" = "/" ] && arg_error "'/' not permitted as a base directory" "${SYNTAX}"
[ ! -d "${MINIROOTDIR}" ] && arg_error "${MINIROOTDIR} directory does not exist" "${SYNTAX}"
[ "${MINIROOTDIR}" = "/" ] && arg_error "'/' is definitely not a valid miniroot directory" "${SYNTAX}"

# Create pulsaros full archive 
msg_to_stderr "copy kernel to boot directory"
cp ${MINIROOTDIR}/platform/i86pc/kernel/unix ${BASEDIR}/boot/boot/platform/i86pc/kernel/
msg_to_stderr "creating full miniroot_archive"
mkfile 210m ${BASEDIR}/boot/boot/${IMAGE}
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
# create initial .version
echo "0.3alpha\t000" > /pulsar_boot/pulsarroot/bin/.version
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
mkfile 50m ${BASEDIR}/boot/${IMAGE}_update
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
echo "kernel /boot/platform/i86pc/kernel/unix -v" >> ${BASEDIR}/boot/boot/grub/menu.lst
echo "module /boot/${IMAGE}.gz" >> ${BASEDIR}/boot/boot/grub/menu.lst

exit 0
