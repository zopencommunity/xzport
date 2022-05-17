#!/bin/sh
#
# Set up environment variables for general build tool to operate
#
if ! [ -f ./setenv.sh ]; then
	echo "Need to source from the setenv.sh directory" >&2
	return 0
fi

export PORT_ROOT="${PWD}"
unset PORT_TARBALL
unset PORT_GIT
export PORT_TARBALL="Y"
#export PORT_GIT="Y"
export PORT_TARBALL_URL="https://tukaani.org/xz/xz-5.2.5.tar.gz"
export PORT_TARBALL_DEPS="curl gzip make"

export PORT_GIT_URL="https://git.tukaani.org/xz.git"
export PORT_GIT_DEPS="git make"

export PORT_EXTRA_CFLAGS=""
export PORT_EXTRA_LDFLAGS=""
