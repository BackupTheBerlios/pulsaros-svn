#!/bin/sh

#
# addrtls.sh - Add rtls driver to the miniroot in order to support network
#              functionality for this specific device.
#
#              This script is typically invoked from ant and has the
#              following arguments: 
#
#              $1: media_dir - Directory where Solaris install packages exist
#              $2: build_dir - Base build directoy
#

PROGNAME=$0
SYNTAX="${PROGNAME} solaris_media_dir build_dir"

. ../include/utils.sh

if [ $# != 2 ] ; then
    arg_error "Wrong number of arguments" "${SYNTAX}"
fi

if [ ! -d $1 ] ; then
    arg_error "\"$1\": media directory not found" "${SYNTAX}"
else
    PKGDIR=$1
fi

if [ ! -d $2 ] ; then
    arg_error "\"$2\": build directory not found" "${SYNTAX}"
else
    BUILDDIR=$2
    PKGLOG=${BUILDDIR}/packages.log
    MINIROOTDIR=${BUILDDIR}/miniroot
    if [ ! -d ${MINIROOTDIR} ] ; then
        errormsg_and_exit \
            "\"${MINIROOTDIR}\" must be populated prior to running this script"
    fi
fi

# cp vel driver to miniroot
HOME=${BUILDDIR}/platform/driver/vel
echo 'vel "pci1106,3119"' >> ${MINIROOTDIR}/etc/driver_aliases
echo "vel:* 0600 root sys" >> ${MINIROOTDIR}/etc/minor_perm
echo "vel 999" >> ${MINIROOTDIR}/etc/name_to_major
cp ${HOME}/vel ${MINIROOTDIR}/kernel/drv/


exit 0
