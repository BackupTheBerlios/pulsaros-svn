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

# Remove various usr/lib (non shared object)
echo "\tremoving components (non shared objects) from usr/lib: \c" >&2
USR_LIB_REMOVAL="vplot term t[0-9]* spell rcm iconv diff3prog diffh newsyslog nscd_nischeck calprog fp getoptcvt gmsgfmt help initrd localdef lwp makekey more .help patchmod platexec embedded_su mdb rsh kssladm abi class link_audit"
for component in ${USR_LIB_REMOVAL}
do
    rm -rf ${MINIROOTDIR}/usr/lib/${component}
    echo "${component} \c" >&2
done
echo >&2

# Remove various components in usr (not bin)
echo "\tremoving components (not bin) from usr: \c" >&2
USR_REMOVAL="kvm mail preserve pub share/src share/doc share/man share/lib/{dict,keytables,mailx,pub,tabset,termcap,unittab,xml,zoneinfo} mailx spool news old src"
for component in ${USR_REMOVAL}
do
  rm -rf ${MINIROOTDIR}/usr/${component}
  echo "${component} \c" >&2
done
echo >&2

# Remove unnecessary executables
msg_to_stderr "removing unnecessary executables"
REMOVE_BIN=`cat ../misc/REMOVE_BIN`
for bin in $REMOVE_BIN
do
  rm -rf ${MINIROOTDIR}/${bin}
done

# Remove unnecessary libs
msg_to_stderr "removing unnecessary libaries"
REMOVE_LIB=`cat ../misc/REMOVE_LIB`
for lib in $REMOVE_LIB
do
  printf "${MINIROOTDIR}/${lib}\n"
  rm -rf ${MINIROOTDIR}/${lib}
done

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
find ! -type d| xargs strip

exit 0