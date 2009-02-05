#!/bin/sh

#
# fiximage.sh - Make configuration changes to the miniroot
#
#               This script is typically invoked from ant and has the
#               following arguments: 
#
#               $1: miniroot_directory
#
HOME=/installer/trunk
PROGNAME=$0
SYNTAX="${PROGNAME} minroot_directory"

. ../include/utils.sh

if [ $# != 1 ] ; then
	arg_error "miniroot_directory argument expected" "${SYNTAX}"
fi

MINIROOTDIR=$1
if [ ! -d "${MINIROOTDIR}" ] ; then
        arg_error "${MINIROOTDIR} directory does not exist" "${SYNTAX}"
fi
if [ "${MINIROOTDIR}" = "/" ] ; then
        arg_error "'/' is definitely not a valid miniroot directory" "${SYNTAX}"
fi

cd ${MINIROOTDIR}

# Copy devfsadm over to /sbin
cp ${MINIROOTDIR}/usr/sbin/devfsadm ${MINIROOTDIR}/sbin/
mkdir ${MINIROOTDIR}/lib/devfsadm
cp -r ${MINIROOTDIR}/usr/lib/devfsadm/linkmod ${MINIROOTDIR}/lib/devfsadm/

#
# Fix etc/vfstab
#
msg_to_stderr "fix /etc/vfstab"
echo "/devices/ramdisk:a - / ufs - no nologging" >> ${MINIROOTDIR}/etc/vfstab
echo "swap - /var tmpfs - yes -" >> ${MINIROOTDIR}/etc/vfstab

#
# Set nodename
#
msg_to_stderr "setting nodename"
echo "pulsar-os" > ${MINIROOTDIR}/etc/nodename

#
# Tar up the /var directory.  At boot time, the /var directory will be
# untarred into a ramdisk partition.
#
msg_to_stderr "tar up /var directory for future re-constitution"
tar cf ./var.tar ./var
/bin/rm -rf ./var/*

#
# Create /pulsarroot directory
#
mkdir  ${MINIROOTDIR}/pulsarroot

#
# copy grub dir
#
if [ -f ${BASEDIR}/boot/boot/grub ]; then
  rm -r ${BASEDIR}/boot/boot/grub
fi
cd ${MINIROOTDIR} && cp -r boot/grub ${BASEDIR}/boot/boot/
REMOVE_GRUB="e2fs_stage1_5 fat_stage1_5 ffs_stage1_5 jfs_stage1_5 minix_stage1_5 pxegrub reiserfs_stage1_5 vstafs_stage1_5 xfs_stage1_5 zfs_stage1_5"
for i in ${REMOVE_GRUB}; do
  rm ${BASEDIR}/boot/boot/grub/$i
done

#
# Set PATH
#
echo "PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/sfw/bin:/usr/ccs/bin:/pulsarroot/bin" > ${MINIROOTDIR}/root/.profile
echo "export PATH" >> ${MINIROOTDIR}/root/.profile

exit 0
