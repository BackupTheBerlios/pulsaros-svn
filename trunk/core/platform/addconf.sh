#!/bin/sh
# Description: 	addconf.sh - Add additional config to the
#				miniroot
# Version:		0.3
#===========================================================

# Variables
PROGNAME=$0
SYNTAX="${PROGNAME} solaris_media_dir build_dir"

# Check syntax
. ../include/utils.sh
[ $# != 2 ] && arg_error "Wrong number of arguments" "${SYNTAX}"

if [ ! -d $1 ] ; then
    arg_error "\"$1\": media directory not found" "${SYNTAX}"
else
    PKGDIR=$1
fi

# Add packages to the system
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

exit 0