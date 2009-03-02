#!/bin/sh
# Description: 	addpkgs.sh - Add selected packages to the miniroot
# Version:		0.3
#=================================================================

# Variables
PROGNAME=$0
SYNTAX="${PROGNAME} PACKAGES_file solaris_media_dir build_dir"

# Syntax check
. ../include/utils.sh
[ $# != 3 ] && arg_error "Wrong number of arguments" "${SYNTAX}"

if [ ! -f $1 ] ; then
    arg_error "$1: file not found" "${SYNTAX}"
else
    PKGLIST=$1
fi

if [ ! -d $2 ] ; then
    arg_error "$2: media directory not found" "${SYNTAX}"
else
    PKGDIR=$2
fi

if [ ! -d $3 ] ; then
    arg_error "$3: build directory not found" "${SYNTAX}"
else
    BUILDDIR=$3
    PKGLOG=${BUILDDIR}/packages.log
    MINIROOTDIR=${BUILDDIR}/miniroot
    if [ ! -d ${MINIROOTDIR} ] ; then
        mkdir ${MINIROOTDIR}
    fi
fi

# Create an admin file for pkgadd(1M)
if [ ! -f /var/sadm/install/admin/default ] ; then
    errormsg_and_exit "can't make pkgadd(1M) admin file"
else
    ADMINFILE=/tmp/admin_file$$
    sed 's/ask/nocheck/' /var/sadm/install/admin/default > ${ADMINFILE}
fi

cat /dev/null > ${PKGLOG}

for pkg in `cat ${PKGLIST}`; do
    if [ ! -d "${PKGDIR}/$pkg" ]; then
        errormsg_and_exit "$pkg not found in ${PKGDIR}"
    else
        msg_to_stderr "$pkg added to ${MINIROOTDIR}"
        pkgadd -d ${PKGDIR} -a ${ADMINFILE} -R ${MINIROOTDIR} $pkg >> ${PKGLOG} 2>&1
        if [ $? != 0 ] ; then
            errormsg_and_exit "pkgadd of $pkg returned error status"
            exit 1
        fi
    fi
done

rm ${ADMINFILE}

exit 0