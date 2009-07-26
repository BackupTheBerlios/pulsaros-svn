#!/bin/sh
# Description: 	wget.sh - Add wget to the miniroot
# Version:	0.3
#===========================================================

# Variables
MINIROOTDIR=$1
HOME=$2

# Copy wget to miniroot
cp -r ${HOME}/bin/* ${MINIROOTDIR}/usr/bin/
cp -r ${HOME}/etc/* ${MINIROOTDIR}/etc/
