#!/bin/sh
# Description: 	adddriver.sh - Add driver to the miniroot in
#				order to support network functionality for 
#				this specific device.
# Version:		0.3
#===========================================================

# Variables
PROGNAME=$0
SYNTAX="${PROGNAME} build_dir"

# Check Syntax
. ../include/utils.sh
[ $# != 1 ] && arg_error "Wrong number of arguments" "${SYNTAX}"

if [ ! -d $1 ] ; then
  arg_error "\"$1\": build directory not found" "${SYNTAX}"
else
  BUILDDIR=$1
  MINIROOTDIR=${BUILDDIR}/miniroot
  if [ ! -d ${MINIROOTDIR} ] ; then
    errormsg_and_exit \
    "\"${MINIROOTDIR}\" must be populated prior to running this script"
  fi
fi

# Copy driver to miniroot
for i in `cat driverlist`; do
  HOME=${BUILDDIR}/platform/driver/${i}
  ${HOME}/${i}.sh $MINIROOTDIR $HOME
done

exit 0