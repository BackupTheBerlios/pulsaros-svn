#!/bin/sh
# Copyright 2009 Thomas Brandstetter. All rights reserved.
# Description: 	fiximage.sh - Make configuration changes to the miniroot
# Version:		0.3
#===========================================================

# Variables
PROGNAME=$0
MINIROOTDIR=$1
SYNTAX="${PROGNAME} minroot_directory"

# Syntax check
. ../include/utils.sh
[ $# != 1 ] && arg_error "miniroot_directory argument expected" "${SYNTAX}"
[ ! -d "${MINIROOTDIR}" ] && arg_error "${MINIROOTDIR} directory does not exist" "${SYNTAX}"
[ "${MINIROOTDIR}" = "/" ] && arg_error "'/' is definitely not a valid miniroot directory" "${SYNTAX}"

cd ${MINIROOTDIR}

# Copy devfsadm over to /sbin
cp ${MINIROOTDIR}/usr/sbin/devfsadm ${MINIROOTDIR}/sbin/
mkdir ${MINIROOTDIR}/lib/devfsadm
cp -r ${MINIROOTDIR}/usr/lib/devfsadm/linkmod ${MINIROOTDIR}/lib/devfsadm/

# Fix etc/vfstab
msg_to_stderr "fix /etc/vfstab"
echo "/devices/ramdisk:a - / ufs - no nologging" >> ${MINIROOTDIR}/etc/vfstab
echo "swap - /var tmpfs - yes -" >> ${MINIROOTDIR}/etc/vfstab

# Set nodename
msg_to_stderr "setting nodename"
echo "pulsar-os" > ${MINIROOTDIR}/etc/nodename

# Tar up the /var directory.  At boot time, the /var directory will be
# untarred into a ramdisk partition.
msg_to_stderr "tar up /var directory for future re-constitution"
tar cf ./var.tar ./var
/bin/rm -rf ./var/*

# Create /pulsarroot directory
mkdir ${MINIROOTDIR}/pulsarroot

# copy and modify grub dir
[ -f ${BASEDIR}/boot/boot/grub ] && rm -r ${BASEDIR}/boot/boot/grub
cd ${MINIROOTDIR} && cp -r boot/grub ${BASEDIR}/boot/boot/
REMOVE_GRUB="e2fs_stage1_5 fat_stage1_5 ffs_stage1_5 jfs_stage1_5 minix_stage1_5 pxegrub reiserfs_stage1_5 vstafs_stage1_5 xfs_stage1_5 zfs_stage1_5"
for i in ${REMOVE_GRUB}; do
  rm ${BASEDIR}/boot/boot/grub/$i
done

# Set PATH
echo "PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/sfw/bin:/usr/ccs/bin:/pulsarroot/bin" > ${MINIROOTDIR}/root/.profile
echo "export PATH" >> ${MINIROOTDIR}/root/.profile
echo "/pulsarroot/bin/setup/setup.sh" >> ${MINIROOTDIR}/root/.profile

exit 0