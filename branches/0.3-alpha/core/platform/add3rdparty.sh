#!/bin/sh
# Description: 	add3rdparty.sh - Add 3rdparty to the miniroot
#		in order to support additional functionality 
# Version:	0.3
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

# Copy 3rdparty to miniroot
for i in `cat 3rdpartylist`; do
  HOME=${BUILDDIR}/platform/3rdparty/${i}
  ${HOME}/${i}.sh $MINIROOTDIR $HOME
done

exit 0
