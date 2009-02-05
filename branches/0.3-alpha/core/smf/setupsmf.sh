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
msg_to_stderr "repository.db"
SVCCFG_REPOSITORY=${MINIROOTDIR}/etc/svc/repository.db
SVCCFG=/usr/sbin/svccfg

export SVCCFG_DTD SVCCFG_REPOSITORY SVCCFG

${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/milestone/sysconfig.xml

#
# turnon boot-archive, manifest-import
#
${SVCCFG} -s system/boot-archive setprop start/exec=:true
${SVCCFG} -s system/manifest-import setprop start/exec=:true

#
# Use Modified fs-minimal and fs-root service which:
#    (1) Mounts /var as a tmpfs
#    (2) After mounting root, removes a previously allocated /FREESPACE file
#        to get some amount of free space in the root directory.
#    (3) Mount /usr to init system
#
msg_to_stderr "modifying filesystem services"
cp ${SMFDIR}/fs-minimal ./lib/svc/method/
cp ${SMFDIR}/fs-root ./lib/svc/method/
chown root:bin ./lib/svc/method/fs-minimal
chmod 555 ./lib/svc/method/fs-minimal
chown root:bin ./lib/svc/method/fs-root
chmod 555 ./lib/svc/method/fs-root
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/filesystem/minimal-fs.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/filesystem/root-fs.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/network/network-service.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/network/smb/server.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/network/samba.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/idmap.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/network/rpc/bind.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/sysidtool.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/milestone/network.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/system-log.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/iscsi_target.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/hostid.xml
${SVCCFG} -s system/idmap:default setprop general/enabled=true
${SVCCFG} -s network/rpc/bind:default setprop general/enabled=true
${SVCCFG} -s system/sysidtool:net setprop general/enabled=true
${SVCCFG} -s system/identity:domain setprop general/enabled=true
${SVCCFG} -s milestone/network:default setprop general/enabled=true
${SVCCFG} -s network/service:default setprop general/enabled=true
${SVCCFG} -s system/system-log:default setprop general/enabled=true
${SVCCFG} -s system/hostid:default setprop general/enabled=true

msg_to_stderr "delete unecessary services"
#${SVCCFG} delete network/rpc/bind
${SVCCFG} delete system/metainit
${SVCCFG} delete network/physical:nwam
#${SVCCFG} delete system/identity:domain
${SVCCFG} delete network/inetd-upgrade

#
# Here's what needed to add ssh to the miniroot
#
msg_to_stderr "adding system/cryptosvc manifest needed for ssh"
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/cryptosvc.xml
${SVCCFG} -s system/cryptosvc:default setprop general/enabled=true

msg_to_stderr "adding network/rpc/gss manifest needed for ssh"
#${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/network/rpc/gss.xml
#${SVCCFG} -s network/rpc/gss:default setprop general/enabled=false

msg_to_stderr "adding network/ssh manifest"
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/network/ssh.xml
${SVCCFG} -s network/ssh:default setprop general/enabled=true

msg_to_stderr "create RSA/DSA keys for ssh"
/usr/bin/ssh-keygen -q -f ${MINIROOTDIR}/etc/ssh/ssh_host_rsa_key -t rsa -N ''
/usr/bin/ssh-keygen -q -f ${MINIROOTDIR}/etc/ssh/ssh_host_dsa_key -t dsa -N ''

msg_to_stderr "edit etc/ssh/sshd_config to allow ssh to root account"
ex -s ${MINIROOTDIR}/etc/ssh/sshd_config > /dev/null << END_OF_INPUT 
/PermitRootLogin
s/no/yes
w!
q
END_OF_INPUT
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
# End ssh stuff

exit 0
