#!/bin/sh
# Copyright 2009 Thomas Brandstetter. All rights reserved.
# Description: 	trim.sh - Remove unnecessary miniroot components
# Version:		0.3
#===============================================================

# Variables
PROGNAME=$0
MINIROOTDIR=$1
SYNTAX="${PROGNAME} minroot_directory"

# Syntax check
. ../include/utils.sh
[ $# != 1 ] && arg_error "miniroot_directory argument expected" "${SYNTAX}"
[ ! -d "${MINIROOTDIR}" ] && arg_error "${MINIROOTDIR} directory does not exist" "${SYNTAX}"
[ "${MINIROOTDIR}" = "/" ]&& arg_error "'/' is definitely not a valid miniroot directory" "${SYNTAX}"

cd ${MINIROOTDIR}

# Remove amd64 binaries and man pages 
msg_to_stderr "removing amd64 binaries and man pages"
find . -name amd64 | xargs rm -r 2> /dev/null
find . -name 64 | xargs rm -r 2> /dev/null
find . -name man | xargs rm -r 2> /dev/null

# needed for GD
mv usr/X11/lib/libX11.so.4 usr/X11/lib/libXext.so.0 usr/X11/lib/libXau.so.6 usr/X11/lib/libXevie.so.1 usr/X11/lib/libXss.so.1 usr/X11/lib/libXpm* .
rm -rf usr/X11/* && mkdir usr/X11/lib && chown root:bin usr/X11/lib
mv libX11.so.4 libXext.so.0 libXau.so.6 libXevie.so.1 libXss.so.1 libXpm* usr/X11/lib/
ln -s /usr/X11/lib/libXpm.so.4 usr/lib/libXpm.so.4
ln -s /usr/lib/libXpm.so.4 usr/lib/libXpm.so
ln -s /usr/X11/lib/libX11.so.4 usr/lib/libX11.so.4
ln -s /usr/X11/lib/libX11.so.4 usr/lib/libX11.so.5
ln -s /usr/lib/libX11.so.4 usr/lib/libX11.so

# Remove unesessary kernel modules
msg_to_stderr "removing unnecessary kernel modules"
REMOVE_KERNEL=`cat ../misc/REMOVE_KERNEL`
for kernel in $REMOVE_KERNEL
do
  rm -rf ${MINIROOTDIR}/${kernel}
done 

# Remove packaging, xpg4
msg_to_stderr "removing packaging, xpg4, swat and else"
rm -rf var/sadm/* usr/xpg4 usr/sfw/swat usr/openwin/bin usr/openwin/server usr/mysql/5.0/docs usr/demo usr/games usr/include usr/lib/cups usr/lib/spell usr/share/lib/dict usr/share/cups usr/share/icons usr/openwin/lib/app-defaults usr/openwin/share/include usr/openwin/share/src lib/mpxio lib/crypto usr/lib/inet usr/lib/crypto lib/libmvec

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
find *| xargs strip

# repackage perl to a plugin
[ -d /installer/plugins/perl/application/perl5.tar ] && rm /installer/plugins/perl/application/perl5.tar
cd  ${MINIROOTDIR}/usr && tar -cf /installer/plugins/perl/application/perl5.tar perl5
rm -r perl5


# repackage mysql to a plugin
[ -d /installer/plugins/mysql/application/mysql.tar ] && rm /installer/plugins/mysql/application/mysql.tar
cd  ${MINIROOTDIR}/usr && tar -cf /installer/plugins/mysql/application/mysql.tar mysql
rm -r mysql

# repackage bash to a plugin
[ -d /installer/plugins/bash/application/bash ] && rm /installer/plugins/bash/application/bash
cd  ${MINIROOTDIR}/usr/bin && cp -rp bash /installer/plugins/bash/application/
rm bash

exit 0
