#!/bin/sh
# Copyright 2009 Thomas Brandstetter. All rights reserved.
# Description: 	fiximage.sh - Make configuration changes to the miniroot
# Version:		0.4
#===========================================================

# Variables
PROGNAME=$0
MINIROOTDIR=$1
BASEDIR=$2
SYNTAX="${PROGNAME} miniroot_directory"

# Syntax check
. ../include/utils.sh
[ $# != 2 ] && arg_error "miniroot_directory argument expected" "${SYNTAX}"
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

# Set PATH
echo "PATH=$PATH:/bin:/sbin:/usr/bin:/usr/bin/amd64:/usr/sbin:/usr/sbin/amd64:/usr/sfw/bin:/usr/ccs/bin:/pulsarroot/bin" > ${MINIROOTDIR}/root/.profile
echo "export PATH" >> ${MINIROOTDIR}/root/.profile

# create new global profile
cp ${BASEDIR}/platform/pulsarroot/bin/setup/profile ${MINIROOTDIR}/etc/profile

exit 0