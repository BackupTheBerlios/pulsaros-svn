#!/bin/sh
# Description: 	vel.sh - Add vel driver to the miniroot in
#				order to support network functionality for 
#				this specific device.
# Version:		0.3
#===========================================================

# Variables
MINIROOTDIR=$1
HOME=$2

# Copy vel driver to miniroot
echo 'vel "pci1106,3119"' >> ${MINIROOTDIR}/etc/driver_aliases
echo "vel:* 0600 root sys" >> ${MINIROOTDIR}/etc/minor_perm
echo "vel 999" >> ${MINIROOTDIR}/etc/name_to_major
cp ${HOME}/vel ${MINIROOTDIR}/kernel/drv/