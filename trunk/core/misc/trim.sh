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

# copy libssl.so.0.9.8 to usr/lib
cp /usr/sfw/lib/libssl.so.0.9.8 usr/lib/libssl.so.0.9.8
cp /usr/sfw/lib/libcrypto.so.0.9.8 usr/lib/libcrypto.so.0.9.8

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
# Remove unesessary libs
rm -rf usr/demo usr/games usr/include usr/lib/cups 
rm usr/lib/libike.so.1
rm usr/lib/nss_winbind.so usr/lib/nss_winbind.so.1
rm usr/lib/nss_wins.so usr/lib/nss_wins.so.1
rm usr/lib/adb/adbgen* /usr/lib/adb/adbsub.o
rm usr/lib/madv.so.1 usr/lib/mpss.so.1 
rm -rf usr/lib/spell
rm usr/proc/bin/pwait
rm -rf usr/share/lib/dict
rm kernel/kmdb/smbsrv
rm kernel/kmdb/zfs
rm kernel/drv/kmdb
rm kernel/drv/kmdb.conf
rm kernel/misc/kmdbmod
rm usr/lib/mdb/kvm/smbsrv.so
rm usr/lib/smbsrv/llib-lmlrpc
rm usr/lib/smbsrv/llib-lmlrpc.ln
rm usr/lib/smbsrv/llib-lmlsvc
rm usr/lib/smbsrv/llib-lmlsvc.ln
rm usr/lib/smbsrv/llib-lsmb
rm usr/lib/smbsrv/llib-lsmb.ln
rm usr/lib/smbsrv/llib-lsmbns
rm usr/lib/smbsrv/llib-lsmbns.ln
rm usr/lib/smbsrv/llib-lsmbrdr
rm usr/lib/smbsrv/llib-lsmbrdr.ln
rm usr/lib/smbsrv/llib-ltecla
rm usr/lib/smbsrv/llib-ltecla.ln
rm usr/lib/llib-lzfs
rm usr/lib/llib-lzfs.ln
rm usr/lib/mdb/kvm/zfs.so
rm usr/lib/mdb/proc/libzpool.so
rm usr/ccs/lib/link_audit
rm usr/lib/abi/spec2map
rm usr/lib/abi/spec2trace
rm usr/lib/ld/map.bssalign
rm usr/lib/ld/map.default
rm usr/lib/ld/map.execdata
rm usr/lib/ld/map.noexdata
rm usr/lib/ld/map.noexstk
rm usr/lib/ld/map.pagealign
rm usr/lib/libldstab.so.1
rm usr/lib/link_audit/ldprof.so.1
rm usr/lib/link_audit/truss.so.1
rm usr/lib/link_audit/who.so.1


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

#
# Remove various usr/lib (non shared object)
#
echo "\tremoving components (non shared objects) from usr/lib: \c" >&2
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

#
# Remove unneeded perl files
#
rm usr/perl5/5.8.4/bin/xsubpp
rm usr/perl5/5.8.4/bin/splain
rm usr/perl5/5.8.4/bin/s2p
rm usr/perl5/5.8.4/bin/pstruct
rm usr/perl5/5.8.4/bin/psed
rm usr/perl5/5.8.4/bin/prove
rm usr/perl5/5.8.4/bin/podselect
rm usr/perl5/5.8.4/bin/podchecker
rm usr/perl5/5.8.4/bin/pod2usage
rm usr/perl5/5.8.4/bin/pod2text
rm usr/perl5/5.8.4/bin/pod2man
rm usr/perl5/5.8.4/bin/pod2latex
rm usr/perl5/5.8.4/bin/pod2html
rm usr/perl5/5.8.4/bin/pl2pm
rm usr/perl5/5.8.4/bin/piconv
rm usr/perl5/5.8.4/bin/libnetcfg
rm usr/perl5/5.8.4/bin/instmodsh
rm usr/perl5/5.8.4/bin/h2xs
rm usr/perl5/5.8.4/bin/h2ph
rm usr/perl5/5.8.4/bin/find2perl
rm usr/perl5/5.8.4/bin/enc2xs
rm usr/perl5/5.8.4/bin/dprofpp
rm usr/perl5/5.8.4/bin/cpan
rm usr/perl5/5.8.4/bin/c2ph
rm usr/perl5/5.8.4/bin/a2p
rm -r usr/perl5/5.8.4/lib/IO
rm -r usr/perl5/5.8.4/lib/PerlIO
rm -r usr/perl5/5.8.4/lib/Sun
rm -r usr/perl5/5.8.4/lib/auto
rm -r usr/perl5/5.8.4/lib/Attribute
rm -r usr/perl5/5.8.4/lib/Carp
rm -r usr/perl5/5.8.4/lib/Class
rm -r usr/perl5/5.8.4/lib/Digest
rm -r usr/perl5/5.8.4/lib/Exporter
rm -r usr/perl5/5.8.4/lib/File
rm -r usr/perl5/5.8.4/lib/Filter
rm -r usr/perl5/5.8.4/lib/Getopt
rm -r usr/perl5/5.8.4/lib/Hash
rm -r usr/perl5/5.8.4/lib/IPC
rm -r usr/perl5/5.8.4/lib/List
rm -r usr/perl5/5.8.4/lib/Math
rm -r usr/perl5/5.8.4/lib/Scalar
rm -r usr/perl5/5.8.4/lib/Search
rm -r usr/perl5/5.8.4/lib/Term
rm -r usr/perl5/5.8.4/lib/Text
rm -r usr/perl5/5.8.4/lib/Tie
rm -r usr/perl5/5.8.4/lib/Time
rm -r usr/perl5/5.8.4/lib/User
rm -r usr/perl5/5.8.4/lib/B
rm -r usr/perl5/5.8.4/lib/CPAN
rm -r usr/perl5/5.8.4/lib/DBM_Filter
rm -r usr/perl5/5.8.4/lib/Devel
rm -r usr/perl5/5.8.4/lib/Encode
rm -r usr/perl5/5.8.4/lib/ExtUtils
rm -r usr/perl5/5.8.4/lib/I18N
rm -r usr/perl5/5.8.4/lib/Locale
rm -r usr/perl5/5.8.4/lib/Memoize
rm -r usr/perl5/5.8.4/lib/Net
rm -r usr/perl5/5.8.4/lib/Pod
rm -r usr/perl5/5.8.4/lib/Test
rm -r usr/perl5/5.8.4/lib/Unicode
rm -r usr/perl5/5.8.4/lib/pod
rm -r usr/perl5/5.8.4/lib/unicore
rm -r usr/perl5/5.8.4/lib/i86pc-solaris-64int

#
# Strip libraries and binaries
#
strip bin/*
strip bin/i86/*
strip lib/*
strip lib/svc/*
strip lib/svc/bin/*
strip lib/svc/capture/*
strip lib/svc/method/*
strip lib/inet/*
strip lib/mpxio/*
strip lib/libmvec/*
strip lib/crypto/*
strip lib/devfsadm/linkmod/*
strip sbin/*
strip usr/bin/*
strip usr/bin/i86/*
strip usr/lib/*
strip usr/lib/libc/*
strip usr/lib/libsoftcrypto/*
strip usr/lib/devfsadm/linkmod/*
strip usr/lib/inet/*
strip usr/lib/pci/*
strip usr/lib/saf/*
strip usr/lib/sysevent/*
strip usr/lib/sysevent/modules/*
strip usr/lib/smbsrv/*
strip usr/lib/ssh/*
strip usr/lib/fs/*/*
strip usr/lib/zfs/*
strip usr/lib/gss/*
strip usr/lib/cfgadm/*
strip usr/lib/dns/*
strip usr/lib/raidcfg/*
strip usr/lib/scsi/*
strip usr/lib/adb/*
strip usr/lib/sasl/*
strip usr/lib/krb5/*
strip usr/lib/security/*
strip usr/lib/mps/*
strip usr/mysql/5.0/bin/*
strip usr/mysql/5.0/lib/*
strip usr/openwin/lib/*
strip usr/openwin/sfw/lib/*
strip usr/X11/lib/*

exit 0
