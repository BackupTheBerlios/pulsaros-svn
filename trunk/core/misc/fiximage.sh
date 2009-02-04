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
#echo "/dev/dsk/c0d0s1 /dev/rdsk/c0d0s1 /usr ufs - no nologging" >> ${MINIROOTDIR}/etc/vfstab
#echo "/dev/dsk/c0d0s0 /dev/rdsk/c0d0s0 /coreroot ufs - yes nologging" >> ${MINIROOTDIR}/etc/vfstab

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
# Create /coreroot directory
#
mkdir  ${MINIROOTDIR}/coreroot

#
# Set PATH
#
echo "PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/sfw/bin:/usr/ccs/bin:/coreroot/bin" > ${MINIROOTDIR}/root/.profile
echo "export PATH" >> ${MINIROOTDIR}/root/.profile

exit 0
