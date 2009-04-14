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

# Variables
PROGNAME=$0
SYNTAX="${PROGNAME} minroot_directory smf_directory"
MINIROOTDIR=$1
SMFDIR=$2

. ../include/utils.sh

# Syntax check
[ $# != 2 ] && arg_error "wrong number of arguments" "${SYNTAX}"
[ ! -d "${MINIROOTDIR}" ] && arg_error "${MINIROOTDIR} directory does not exist" "${SYNTAX}"
[ "${MINIROOTDIR}" = "/" ]&& arg_error "'/' is definitely not a valid miniroot directory" "${SYNTAX}"
[ ! -d "${SMFDIR}" ] && arg_error "${SMFDIR} directory does not exist" "${SYNTAX}"

cd ${MINIROOTDIR}

# Set the environment variables for svccfg.
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
# Use Modified fs-minimal and fs-root services
msg_to_stderr "modifying filesystem services"
cp ${SMFDIR}/fs-minimal ./lib/svc/method/
cp ${SMFDIR}/fs-root ./lib/svc/method/
cp ${SMFDIR}/svc-hostid ./lib/svc/method/
chown root:bin ./lib/svc/method/fs-minimal
chmod 555 ./lib/svc/method/fs-minimal
chown root:bin ./lib/svc/method/fs-root
chmod 555 ./lib/svc/method/fs-root
chown root:bin ./lib/svc/method/svc-hostid
chmod 555 ./lib/svc/method/svc-hostid
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/filesystem/minimal-fs.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/filesystem/root-fs.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/network/network-service.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/network/smb/server.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/idmap.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/network/rpc/bind.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/sysidtool.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/milestone/network.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/system-log.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/iscsi_target.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/hostid.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/network/shares/group.xml
${SVCCFG} -s system/idmap:default setprop general/enabled=true
${SVCCFG} -s network/rpc/bind:default setprop general/enabled=true
${SVCCFG} -s system/sysidtool:net setprop general/enabled=true
${SVCCFG} -s system/identity:domain setprop general/enabled=true
${SVCCFG} -s milestone/network:default setprop general/enabled=true
${SVCCFG} -s network/service:default setprop general/enabled=true
${SVCCFG} -s system/system-log:default setprop general/enabled=true
${SVCCFG} -s system/hostid:default setprop general/enabled=true
${SVCCFG} -s network/physical:nwam setprop general/enabled=true

msg_to_stderr "delete unecessary services"
# since snv_107 don't know why....
${SVCCFG} delete system/metainit
${SVCCFG} delete network/inetd-upgrade
${SVCCFG} delete system/svc/global
rm ${MINIROOTDIR}/etc/init.d/autoinstall
rm ${MINIROOTDIR}/etc/init.d/cachefs_daemon
rm ${MINIROOTDIR}/etc/init.d/sysetup
rm ${MINIROOTDIR}/etc/rc2.d/S20sysetup
rm ${MINIROOTDIR}/etc/rc2.d/S72autoinstall
rm ${MINIROOTDIR}/etc/rc2.d/S73cachefs_daemon
rm ${MINIROOTDIR}/etc/rc2.d/S82mkdtab
rm ${MINIROOTDIR}/etc/rc2.d/S89PRESERVE
rm ${MINIROOTDIR}/var/svc/manifest/system/svc/global.xml
rm ${MINIROOTDIR}/var/svc/manifest/application/database/mysql.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/dns/client.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/ipsec/ike.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/ipsec/manual-key.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/ldap/client.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/routing/legacy-routing.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/rpc/keyserv.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/forwarding.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/winbind.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/wins.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/iscsi_initiator.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/device/mpxio-upgrade.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/auditd.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/consadm.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/extended-accounting.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/vtdaemon.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/inetd-upgrade.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/swat.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/rmtmpfiles.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/sysevent.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/cryptosvc.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/ipsec/ipsecalgs.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/ipsec/policy.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/keymap.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/scheduler.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/name-service-cache.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/boot-archive-update.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/cron.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/dumpadm.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/network-routing-setup.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/sac.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/inetd.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/intrd.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/fmd.xml
rm ${MINIROOTDIR}/var/svc/manifest/system/coreadm.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/rpc/gss.xml
rm ${MINIROOTDIR}/var/svc/manifest/network/rpc/keyserv.xml
rm ${MINIROOTDIR}/lib/svc/method/inetd-upgrade
rm ${MINIROOTDIR}/lib/svc/method/ldap-client
rm ${MINIROOTDIR}/lib/svc/method/mpxio-upgrade
rm ${MINIROOTDIR}/lib/svc/method/svc-auditd
rm ${MINIROOTDIR}/lib/svc/method/svc-consadm
rm ${MINIROOTDIR}/lib/svc/method/yp

# Add dropbear service
msg_to_stderr "adding dropbear manifest needed for ssh"
cp ${SMFDIR}/dropbear.xml ./var/svc/manifest/network/
cp ${SMFDIR}/dropbear ./lib/svc/method/
chown root:bin ./lib/svc/method/dropbear
chmod 555 ./lib/svc/method/dropbear
chown root:sys ./var/svc/manifest/network/dropbear.xml
chmod 444 ./var/svc/manifest/network/dropbear.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/network/dropbear.xml
${SVCCFG} -s network/ssh:default setprop general/enabled=true

# Add frontend service
msg_to_stderr "adding frontend manifest"
cp ${SMFDIR}/frontend.xml ./var/svc/manifest/system/
cp ${SMFDIR}/frontend ./lib/svc/method/
chown root:bin ./lib/svc/method/system
chmod 555 ./lib/svc/method/system
chown root:sys ./var/svc/manifest/system/frontend.xml
chmod 444 ./var/svc/manifest/system/frontend.xml
${SVCCFG} import ${MINIROOTDIR}/var/svc/manifest/system/frontend.xml
${SVCCFG} -s system/frontend:default setprop general/enabled=true

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
