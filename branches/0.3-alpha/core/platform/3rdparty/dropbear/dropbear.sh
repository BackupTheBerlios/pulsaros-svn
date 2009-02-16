#!/bin/sh
# Description: 	dropbear.sh - Add dropbear ssh daemon to the 
#		miniroot
# Version:	0.3
#===========================================================

# Variables
MINIROOTDIR=$1
HOME=$2

# Copy dropbear to miniroot
mkdir ${MINIROOTDIR}/etc/dropbear
cp -r ${HOME}/sbin/* ${MINIROOTDIR}/usr/sbin/
cp -r ${HOME}/bin/* ${MINIROOTDIR}/usr/bin/
${MINIROOTDIR}/usr/bin/dropbearkey -f ${MINIROOTDIR}/etc/dropbear/dropbear_rsa_host_key -t rsa -s 2048
