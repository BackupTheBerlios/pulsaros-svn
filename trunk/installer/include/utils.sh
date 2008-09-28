#!/bin/sh

#
# Common utility functions
#

#
# Used in conjunction with ant(1), use this finction to print out
# informational messages while building the custom miniroot.  Messages are
# sent to stderr and prefaced with a tab.
#
# Args:
#    $1 - The message to display
#
msg_to_stderr()
{
	echo "\t$1" >&2
}


#
# Typically used when processing command-line arguments, print an error
# message and correct command-line syntax to stderr then exit.
#
# Args:
#    $1 - The error message
#    $2 - The correct command-line syntax
#
arg_error()
{
    echo $1 >&2
    echo syntax: $2 >&2
    exit 1
}


#
# Print an error message to stderr and exit
#
errormsg_and_exit()
{
    echo "Error: " $1 >&2
    exit 1
}
