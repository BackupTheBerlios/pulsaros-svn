#!/bin/sh
# Description: 	rot47.sh - Add rot47 to the miniroot
# Version:	0.4
#===========================================================

# Variables
MINIROOTDIR=$1
HOME=$2

# Copy rot47 to miniroot
cp -r ${HOME}/bin/* ${MINIROOTDIR}/usr/bin/
