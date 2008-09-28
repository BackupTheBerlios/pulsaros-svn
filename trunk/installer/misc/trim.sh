#!/bin/sh

#
# trim.sh - Remove unnecessary miniroot components
#
#              This script is typically invoked from ant and has the
#              following arguments: 
#
#              $1: miniroot_directory
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
# Remove amd64 binaries
#
msg_to_stderr "removing amd64 binaries"
find . -name amd64 | xargs rm -r 2> /dev/null

#
# Remove packaging, xpg4, sfw
#
msg_to_stderr "removing packaging, xpg4, and freeware"
rm -rf var/sadm/* usr/xpg4 usr/sfw

#
# Remove various usr/lib (non shared object)
#
echo "\tremoving compoenets (non shared objects) from usr/lib: \c" >&2
USR_LIB_REMOVAL="vplot term t[0-9]* spell rcm iconv diff3prog diffh newsyslog nscd_nischeck calprog fp getoptcvt gmsgfmt help initrd localdef lwp makekey more.help patchmod platexec embedded_su mdb rsh kssladm abi class link_audit"
for component in ${USR_LIB_REMOVAL}
do
    rm -rf ${MINIROOTDIR}/usr/lib/${component}
    echo "${component} \c" >&2
done
echo >&2

#
# Remove various components in usr (not bin)
#
echo "\tremoving components (not bin) from usr: \c" >&2
USR_REMOVAL="kvm mail preserve pub share/src share/lib/{dict,keytables,mailx,pub,tabset,termcap,unittab,xml,zoneinfo} mailx spool news old openwin src"
for component in ${USR_REMOVAL}
do
    rm -rf ${MINIROOTDIR}/usr/${component}
    echo "${component} \c" >&2
done
echo >&2

#
# Remove unnecessary executables
#
msg_to_stderr "removing unnecessary executables"
REMOVE_ELFS=`cat ../misc/REMOVE_ELFS`
for elf in $REMOVE_ELFS
do
	rm -rf ${MINIROOTDIR}/${elf}
done

exit 0
