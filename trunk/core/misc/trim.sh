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
# Remove amd64 binaries and man pages 
#
msg_to_stderr "removing amd64 binaries and man pages"
find . -name amd64 | xargs rm -r 2> /dev/null
find . -name 64 | xargs rm -r 2> /dev/null
find . -name man | xargs rm -r 2> /dev/null

#
# Remove packaging, xpg4
#
msg_to_stderr "removing packaging, xpg4, swat and else"
# needed for GD
mv usr/X11/lib/libX11.so.4 usr/X11/lib/libXext.so.0 usr/X11/lib/libXau.so.6 usr/X11/lib/libXevie.so.1 usr/X11/lib/libXss.so.1 usr/X11/lib/libXpm* .
rm -rf usr/X11/* && mkdir usr/X11/lib && chown root:bin usr/X11/lib
mv libX11.so.4 libXext.so.0 libXau.so.6 libXevie.so.1 libXss.so.1 libXpm* usr/X11/lib/
ln -s /usr/X11/lib/libXpm.so.4 usr/lib/libXpm.so.4
ln -s /usr/lib/libXpm.so.4 usr/lib/libXpm.so
ln -s /usr/X11/lib/libX11.so.4 usr/lib/libX11.so.4
ln -s /usr/X11/lib/libX11.so.4 usr/lib/libX11.so.5
ln -s /usr/lib/libX11.so.4 usr/lib/libX11.so
#
rm -rf var/sadm/* usr/xpg4 usr/sfw/swat usr/openwin/bin usr/openwin/server usr/mysql/5.0/docs
rm usr/mysql/5.0/bin/ndb*
rm usr/mysql/5.0/bin/mysqlbug
rm usr/mysql/5.0/bin/mysql_upgrade*
rm usr/mysql/5.0/bin/mysql_client_test
rm usr/mysql/5.0/bin/mysqlbinlog
rm usr/mysql/5.0/bin/mysqladmin
rm usr/mysql/5.0/bin/mysqltestmanager*
rm usr/mysql/5.0/bin/mysql_explain_log
rm usr/mysql/5.0/bin/mysql_secure_installation
rm usr/mysql/5.0/bin/replace
rm usr/mysql/5.0/bin/msql2mysql
rm usr/mysql/5.0/bin/resolve_stack_dump
rm usr/mysql/5.0/bin/perror
rm usr/mysql/5.0/bin/mysqltest
rm usr/mysql/5.0/bin/mysqlmanager
rm usr/mysql/5.0/bin/mysql_zap
rm usr/mysql/5.0/bin/comp_err
rm usr/mysql/5.0/bin/mysql_waitpid
rm usr/mysql/5.0/bin/mysqlaccess
rm usr/mysql/5.0/bin/resolveip
rm usr/mysql/5.0/lib/mysql/libndbclient*
rm usr/mysql/5.0/lib/mysql/libdbug.a

#
# Remove various usr/lib (non shared object)
#
echo "\tremoving compoenets (non shared objects) from usr/lib: \c" >&2
USR_LIB_REMOVAL="vplot term t[0-9]* spell rcm iconv diff3prog diffh newsyslog nscd_nischeck calprog fp getoptcvt gmsgfmt help initrd localdef lwp makekey more
.help patchmod platexec embedded_su mdb rsh kssladm abi class link_audit"
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
USR_REMOVAL="kvm mail preserve pub share/src share/doc share/man share/lib/{dict,keytables,mailx,pub,tabset,termcap,unittab,xml,zoneinfo} mailx spool news old src"
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
