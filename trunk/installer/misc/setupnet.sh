#!/bin/sh

#
# setupnet.sh - Set up the network configuration for this platform
#
#               This script is typically invoked from ant and has the
#               following arguments: 
#
#               $1: miniroot_directory
#

PROGNAME=$0
SYNTAX="${PROGNAME} minroot_directory"
HOSTNAME="core"
#IPADDRESS=192.168.1.2
#INTERFACE=e1000g0
#DEFAULT_ROUTE=DHCP

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
# Set hostname
#
msg_to_stderr "setting hostname"
echo "${HOSTNAME}" > ${MINIROOTDIR}/etc/nodename

#
# Create /etc/inet/hosts and /etc/inet/ipnodes file
#
msg_to_stderr "creating hosts file"
echo "127.0.0.1	localhost loghost" > ${MINIROOTDIR}/etc/inet/hosts
#echo "${IPADDRESS}	${HOSTNAME}" >> ${MINIROOTDIR}/etc/inet/hosts
msg_to_stderr "creating ipnodes file"
echo "::1	localhost loghost" > ${MINIROOTDIR}/etc/inet/ipnodes
echo "127.0.0.1	localhost loghost" >> ${MINIROOTDIR}/etc/inet/ipnodes
#echo "${IPADDRESS}	${HOSTNAME}" >> ${MINIROOTDIR}/etc/inet/ipnodes

#
# Set nsswitch.conf
#
msg_to_stderr "setting nsswitch.conf to nsswitch.files"
cp ${MINIROOTDIR}/etc/nsswitch.files ${MINIROOTDIR}/etc/nsswitch.conf

#
# Set IP Address
#
#msg_to_stderr "setting IP Address" 
#echo "${HOSTNAME}" > ${MINIROOTDIR}/etc/hostname.${INTERFACE}
#echo "wait 10" > ${MINIROOTDIR}/etc/dhcp.${INTERFACE}

#
# Set up default route
#
#msg_to_stderr "setting default route" 
# echo "${DEFAULT_ROUTE}" > ${MINIROOTDIR}/etc/defaultrouter

exit 0
