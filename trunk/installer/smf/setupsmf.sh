#!/bin/sh

#
# setupsmf.sh - Customize SMF for this miniroot configuration
#
#               This script is typically invoked from ant and has the
#               following arguments: 
#
#               $1: miniroot_directory
#               $2: smf_directory: where customized SMF manifests and
#                                  methods exist
#

PROGNAME=$0
SYNTAX="${PROGNAME} minroot_directory smf_directory"

. ../include/utils.sh


if [ $# != 2 ] ; then
	arg_error "wrong number of arguments" "${SYNTAX}"
fi

MINIROOTDIR=$1
if [ ! -d "${MINIROOTDIR}" ] ; then
        arg_error "${MINIROOTDIR} directory does not exist" "${SYNTAX}"
fi
if [ "${MINIROOTDIR}" = "/" ] ; then
        arg_error "'/' is definitely not a valid miniroot directory" "${SYNTAX}"
fi

SMFDIR=$2
if [ ! -d "${SMFDIR}" ] ; then
        arg_error "${SMFDIR} directory does not exist" "${SYNTAX}"
fi

cd ${MINIROOTDIR}

#
# Set the environment variables for svccfg.
#
msg_to_stderr "customize SMF services"
SVCCFG_DTD=${MINIROOTDIR}/usr/share/lib/xml/dtd/service_bundle.dtd.1
SVCCFG_REPOSITORY=${MINIROOTDIR}/etc/svc/repository.db
SVCCFG=/usr/sbin/svccfg

export SVCCFG_DTD SVCCFG_REPOSITORY SVCCFG

${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/milestone/sysconfig.xml

#
# turnoff boot-archive, ipfilter, manifest-import
#
${SVCCFG} -s system/boot-archive setprop start/exec=:true
${SVCCFG} -s system/manifest-import setprop start/exec=:true
${SVCCFG} delete system/metainit

#
# Use Modified fs-minimal,fs-root and keymap  service which:
#    (1) Mounts /var as a tmpfs
#    (2) After mounting root, removes a previously allocated /FREESPACE file
#        to get some amount of free space in the root directory.
#    (3) CAll Libs from /lib instead of /usr/lib to init system
#
msg_to_stderr "modifying filesystem services"
cp ${SMFDIR}/fs-minimal ./lib/svc/method/
chown root:bin ./lib/svc/method/fs-minimal
chmod 555 ./lib/svc/method/fs-minimal
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/filesystem/minimal-fs.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/system-log.xml
${SVCCFG} -s system/system-log:default setprop general/enabled=true

#
# Add a "root" password to the root account.  This is needed for ssh.
#
msg_to_stderr "adding \"root\" password to root account"
ex -s ${MINIROOTDIR}/etc/shadow << END_OF_INPUT 
1d
i
root:v.ggSHu1CbWSo:13362::::::
.
w!
q
END_OF_INPUT

exit 0
