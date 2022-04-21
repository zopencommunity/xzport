#!/bin/sh 
#
# Pre-requisites: 
#  - cd to the directory of this script before running the script   
#  - ensure you have sourced setenv.sh, e.g. . ./setenv.sh
#  - ensure you have GNU make installed (4.1 or later)
#  - ensure you have access to c99
#
#set -x

if [ "${XZ_ROOT}" = '' ]; then
	echo "Need to set XZ_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${XZ_VRM}" = '' ]; then
	echo "Need to set XZ_VRM - source setenv.sh" >&2
	exit 16
fi

if ! make --version >/dev/null 2>&1 ; then
	echo "You need GNU Make on your PATH in order to build XZ" >&2
	exit 16
fi

if ! whence c99 >/dev/null ; then
	echo "c99 required to build XZ. " >&2
	exit 16
fi

MY_ROOT="${PWD}"
if [ "${XZ_VRM}" != "xz" ]; then
	# Non-dev - get the tar file
	rm -rf "${XZ_ROOT}/${XZ_VRM}"
	if ! mkdir -p "${XZ_ROOT}/${XZ_VRM}" ; then
		echo "Unable to make root XZ directory: ${XZ_ROOT}/${XZ_VRM}" >&2
		exit 16
	fi
	cd "${XZ_ROOT}" || exit 99

	if ! [ -f "${XZ_VRM}.tar" ]; then
		echo "xz tar file not found. Attempt to download with curl" 
		if ! whence curl >/dev/null ; then 
			echo "curl not installed. You will need to upload XZ, or install curl/gunzip from ${XZ_URL}" >&2
			exit 16
		fi	
		if ! whence gunzip >/dev/null ; then
			echo "gunzip required to unzip XZ. You will need to upload XZ, or install curl/gunzip from ${XZ_URL}" >&2
			exit 16
		fi	
		if ! (rm -f ${XZ_VRM}.tar.gz; curl -s --cacert ${XZ_CERT} -L --output ${XZ_VRM}.tar.gz ${XZ_MIRROR}/${XZ_VRM}.tar.gz) ; then
			echo "curl failed with rc $rc when trying to download ${XZ_VRM}.tar.gz" >&2
			exit 16
		fi	
		chtag -b ${XZ_VRM}.tar.gz
		if ! gunzip ${XZ_VRM}.tar.gz ; then
			echo "gunzip failed with rc $rc when trying to unzip ${XZ_VRM}.tar.gz" >&2
			exit 16
		fi	
	fi

	tar -xf "${XZ_VRM}.tar" 2>/dev/null

# TBD: figure out how to not update GUID/UID
	if [ $? -gt 1 ] ; then
		echo "Unable to make untar XZ drop: ${XZ_VRM}" >&2
		exit 16
	fi
else
	cd "${XZ_ROOT}" || exit 99
fi
if ! chtag -R -h -t -cISO8859-1 "${XZ_VRM}" ; then
	echo "Unable to tag XZ directory tree as ASCII" >&2
	exit 16
fi

DELTA_ROOT="${PWD}"

if ! managepatches.sh ; then
	echo "Unable to apply patches" >&2
	exit 16
fi

cd "${XZ_ROOT}/${XZ_VRM}"

if [ "${XZ_VRM}" = "xz" ]; then
	./bootstrap
	if [ $? -gt 0 ]; then
		echo "Bootstrap of XZ dev-line failed." >&2
		exit 16
	fi
fi

#
# Setup the configuration so that the system search path looks in lib and include ahead of the standard C libraries
#
export CONFIG_OPTS=""
export CC=xlclang
export CFLAGS="-qascii -Wc,lp64 -Wl,lp64 -D_OPEN_THREADS=3 -D_UNIX03_SOURCE=1 -DNSIG=39"
./configure --prefix="${XZ_PROD}"
if [ $? -gt 0 ]; then
	echo "Configure of XZ tree failed." >&2
	exit 16
fi

cd "${XZ_ROOT}/${XZ_VRM}"
if ! make ; then
	echo "MAKE of XZ tree failed." >&2
	exit 16
fi

if ! make test ; then
	echo "Basic test of XZ failed." >&2
	exit 16
fi

if ! make check ; then
	echo "MAKE check of XZ tree failed." >&2
	exit 16
fi

if ! make install ; then
	echo "MAKE install of XZ tree failed." >&2
	exit 16
fi

echo "xz installed into ${XZ_PROD}"
exit 0
