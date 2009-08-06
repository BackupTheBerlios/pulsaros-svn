#!/bin/sh
# Copyright 2009 Thomas Brandstetter. All rights reserved.
# Description: 	trim.sh - Remove unnecessary miniroot components
# Version:		0.4
#===============================================================

# Variables
PROGNAME=$0
MINIROOTDIR=$1
SYNTAX="${PROGNAME} minroot_directory"
ARCH=$2

# Syntax check
. ../include/utils.sh
[ $# != 2 ] && arg_error "miniroot_directory argument expected" "${SYNTAX}"
[ ! -d "${MINIROOTDIR}" ] && arg_error "${MINIROOTDIR} directory does not exist" "${SYNTAX}"
[ "${MINIROOTDIR}" = "/" ]&& arg_error "'/' is definitely not a valid miniroot directory" "${SYNTAX}"

cd ${MINIROOTDIR}

# Remove amd64 or i386 binaries and man pages, depending of the pulsarOS version
if [ $ARCH = "x86" ]; then
	msg_to_stderr "removing amd64 binaries and man pages"
	find . -name amd64 | xargs rm -r 2> /dev/null
	find . -name 64 | xargs rm -r 2> /dev/null
else
	msg_to_stderr "removing x86 binaries and man pages"
	REMOVE_X86=`cat ../misc/REMOVE_X86`
	for x86 in $REMOVE_X86
	do
  		rm -rf ${MINIROOTDIR}/${x86}
	done
fi
find . -name man | xargs rm -r 2> /dev/null

# Remove unesessary kernel modules
msg_to_stderr "removing unnecessary kernel modules"
REMOVE_KERNEL=`cat ../misc/REMOVE_KERNEL`
for kernel in $REMOVE_KERNEL
do
  rm -rf ${MINIROOTDIR}/${kernel}
done 

# Remove unnecessary executables
msg_to_stderr "removing unnecessary executables"
REMOVE_BIN=`cat ../misc/REMOVE_BIN`
for bin in $REMOVE_BIN
do
  rm -rf ${MINIROOTDIR}/${bin}
done

# Remove unnecessary libs
msg_to_stderr "removing unnecessary libaries"
# Workaround to save UTF-8%646.so (cifs)
cp ${MINIROOTDIR}/usr/lib/iconv/UTF-8%646.so ${MINIROOTDIR}/
REMOVE_LIB=`cat ../misc/REMOVE_LIB`
for lib in $REMOVE_LIB
do
  rm -rf ${MINIROOTDIR}/${lib}
done
# End Workaround to save UTF-8%646.so (cifs
mkdir  ${MINIROOTDIR}/usr/lib/iconv
cp ${MINIROOTDIR}/UTF-8%646.so  ${MINIROOTDIR}/usr/lib/iconv/

# Remove unnecessary other files
msg_to_stderr "removing unnecessary other files"
REMOVE_MYSQL=`cat ../misc/REMOVE_MYSQL`
REMOVE_MISC=`cat ../misc/REMOVE_MISC`
for mysql in $REMOVE_MYSQL
do
  rm -rf ${MINIROOTDIR}/${mysql}
done
for misc in $REMOVE_MISC
do
  rm -rf ${MINIROOTDIR}/${misc}
done

# Strip libraries and binaries
msg_to_stderr "strip files"
cd ${MINIROOTDIR}
for i in `find -type f`; do
	if [ `file $i|grep -c "script"` = 0 ] || [ `file $i|grep -c "ascii"` = 0 ] || [ `file $i|grep -c "empty"` = 0 ]; then
		strip $i
	fi
done

exit 0
