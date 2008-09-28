#!/bin/sh

#
# fiximage.sh - Make configuration changes to the miniroot
#
#               This script is typically invoked from ant and has the
#               following arguments: 
#
#               $1: miniroot_directory
#

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
echo "coreinstaller" > ${MINIROOTDIR}/etc/nodename

#
# Tar up the /var directory.  At boot time, the /var directory will be
# untarred into a ramdisk partition.
#
msg_to_stderr "tar up /var directory for future re-constitution"
tar cf ./var.tar ./var
/bin/rm -rf ./var/*

#
# To have free space in the root filesystem, create a large file and delete
# it at startup.
# 
msg_to_stderr "creating large file on / to be reclaimed as free space"
#mkfile 5m ${MINIROOTDIR}/FREESPACE

# start with the setup screen at startup
echo "#!/bin/sh" > ${MINIROOTDIR}/root/.profile
echo "/root/scripts/setup.sh" >> ${MINIROOTDIR}/root/.profile


exit 0
