#!/bin/sh

#
# bootarchive.sh - Remove unnecessary miniroot components
#
#                  This script is typically invoked from ant and has the
#                  following arguments: 
#
#                  $1: base_directory
#                  $2: miniroot_directory
#                  $3: name of miniroot-image
#

PROGNAME=$0
SYNTAX="${PROGNAME} base_directory minroot_directory miniroot_image"

. ../include/utils.sh

if [ $# != 3 ] ; then
	arg_error "wrong number of arguments" "${SYNTAX}"
fi

BASEDIR=$1
if [ ! -d "${BASEDIR}" ] ; then
        arg_error "${BASEDIR} directory does not exist" "${SYNTAX}"
fi
if [ "${BASEDIR}" = "/" ] ; then
        arg_error "'/' not permitted as a base directory" "${SYNTAX}"
fi

MINIROOTDIR=$2
if [ ! -d "${MINIROOTDIR}" ] ; then
        arg_error "${MINIROOTDIR} directory does not exist" "${SYNTAX}"
fi
if [ "${MINIROOTDIR}" = "/" ] ; then
        arg_error "'/' is definitely not a valid miniroot directory" "${SYNTAX}"
fi

IMAGE=$3


msg_to_stderr "creating miniroot_archive"
#/boot/solaris/bin/root_archive pack ${BASEDIR}/boot/${IMAGE} ${MINIROOTDIR}
#mv ${BASEDIR}/boot/${IMAGE} ${BASEDIR}/boot/${IMAGE}.gz
mkfile 48m ${BASEDIR}/boot/${IMAGE}
lofiadm -a ${BASEDIR}/boot/${IMAGE} > /dev/null 2>&1
yes | newfs -m 0 /dev/rlofi/1 >/dev/null 2>&1
mount /dev/lofi/1 /pulsar_boot
cd ${MINIROOTDIR}
tar -cf /installer/tmp.tar .
cd /pulsar_boot
tar -xf /installer/tmp.tar
rm /installer/tmp.tar
cd /
umount /pulsar_boot
lofiadm -d /dev/lofi/1
rm ${BASEDIR}/boot/${IMAGE}.gz 
gzip -9 ${BASEDIR}/boot/${IMAGE}


msg_to_stderr "creating grub/menu.lst"
echo "default 0" > ${BASEDIR}/boot/grub/menu.lst
echo "timeout 10" >> ${BASEDIR}/boot/grub/menu.lst
echo "title Pulsar v1" >> ${BASEDIR}/boot/grub/menu.lst
echo "kernel /boot/platform/i86pc/kernel/unix -v" >> ${BASEDIR}/boot/grub/menu.lst
echo "module /boot/${IMAGE}.gz" >> ${BASEDIR}/boot/grub/menu.lst

exit 0
