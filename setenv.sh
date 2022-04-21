#!/bin/sh
#set -x

if ! [ -f ./setenv.sh ]; then
	echo "Need to source from the setenv.sh directory" >&2
else
	export _BPXK_AUTOCVT="ON"
	export _CEE_RUNOPTS="FILETAG(AUTOCVT,AUTOTAG),POSIX(ON),TERMTHDACT(MSG)"
	export _TAG_REDIR_ERR="txt"
	export _TAG_REDIR_IN="txt"
	export _TAG_REDIR_OUT="txt"

	export XZ_VRM="xz-5.2.5"
	export XZ_ROOT="${PWD}"
	
        export PATH="${XZ_ROOT}/bin:$PATH"

	export XZ_MIRROR="https://tukaani.org/xz" 
	export XZ_CERT="${XZ_ROOT}/xz.cert"

	fsroot=$( basename $HOME )                         
	export XZ_PROD="/${fsroot}/xzprod"     
fi
