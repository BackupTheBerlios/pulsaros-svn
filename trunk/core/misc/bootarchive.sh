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
if [ -f ${BASEDIR}/boot/${IMAGE}.gz ]; then
  rm ${BASEDIR}/boot/${IMAGE}.gz 
fi
gzip -9 ${BASEDIR}/boot/${IMAGE}


msg_to_stderr "creating grub/menu.lst"
echo "default 0" > ${BASEDIR}/boot/grub/menu.lst
echo "timeout 10" >> ${BASEDIR}/boot/grub/menu.lst
echo "title PulsarOS" >> ${BASEDIR}/boot/grub/menu.lst
echo "kernel /boot/platform/i86pc/kernel/unix -v" >> ${BASEDIR}/boot/grub/menu.lst
echo "module /boot/${IMAGE}.gz" >> ${BASEDIR}/boot/grub/menu.lst
echo "" > ${BASEDIR}/boot/grub/menu.lst
echo "title PulsarOS restore mode" >> ${BASEDIR}/boot/grub/menu.lst
echo "kernel /boot/platform/i86pc/kernel/unix_backup -v" >> ${BASEDIR}/boot/grub/menu.lst
echo "module /boot/${IMAGE}_backup.gz" >> ${BASEDIR}/boot/grub/menu.lst

exit 0
