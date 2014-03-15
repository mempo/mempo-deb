#!/bin/bash

# <mempo>
# mempo-title: Remove timestamps from gz files
# mempo-prio: 2
# mempo-why: To make deterministic deb package possible where gzip is invoked
# mempo-bugfix-deb:
# </mempo>

# work in progress - XXX marks debug code

# TODO isolate this script into a common build-with-patch script
# TODO privacy: set commont timezone e.g. UTC and locale (just to be sure)

# http://mywiki.wooledge.org/BashFAQ/105/ ; http://mywiki.wooledge.org/BashFAQ/101

set -e

# warn: Print a message to stderr. Usage: warn "format" ["arguments"...]
warn() {
  local fmt="$1" ; shift ; printf "ERROR: $fmt\n" "$@" >&2
}
# Usage: some_command || die [status code] "message" ["arguments"...]
die() {
  local st="$?" ; if [[ "$1" != *[^0-9]* ]] ; then st="$1" ; shift ; fi
  warn "$@" ; exit "$st"
}

#~base_dir="$(pwd)" ; [ -z "$base_dir" ] && die "Could not get pwd ($base_dir)" # basic pwd (where our files are)
# echo "Our base_dir is $base_dir [PRIVACY]"  # do not print this because it shows user data

echo "This script will download, build and install locally ($HOME/.local) gzip with a patch to never set the MTIME bytes in the gzip header" ; echo
echo "Please run as ROOT (if needed): apt-get install git build-dep gzip; apt-get install devscripts autoconf automake flex" ; echo
echo ""

gettext_ver=$( LC_ALL=C dpkg -s gettext | grep 'Version' | head -n 1 | sed -e "s/Version: \([^ ]*\).*/\1/" | cut -d'-' -f1 )
echo " * gettext version=$gettext_ver"

. ../dpkg/dpkg-vercomp.sh 

ver_what='gettext'; ver_have=$gettext_ver ; ver_need="0.18.2"
set +e ; vercomp $ver_have $ver_need ; err=$? ; set -e 
case $err in
  2) echo ; echo "ERROR: wrong version of $ver_what"
                echo "We have $ver_have while we need $ver_need" ; 
								echo "Because we need GNU gettext >= 0.18.2, please add \"http://YOURMIRROR.debian.org/debian wheezy-backports\" to /etc/apt/sources.list and run:"
								echo "aptitude update"
								echo "aptitude install -t wheezy-backports gettext autopoint"
								echo "See http://wiki.debian.org/Mempo/ for help"
                exit 1;
        ;;
esac
echo "ok"
echo " * Using $ver_what version $ver_have >= $ver_need - OK"

rm -rf gzip

git clone git://git.gag.com/debian/gzip || die "Can't clone dpkg repository"
cd gzip

git checkout 01862fe8836ddda5a652180653abdaffa143f0c2
echo "Checking repository reference number"
gitver="$(git show-ref --hash --heads)" || die "Can't take repository reference number!"

if [[ "$gitver" == "baf8c7dd1f7954fc9b8b19469f5c3ea5d27d6c85" ]] ; then
echo "OK GIT VERSION: $gitver"
else
die "Github repository reference doesn't match!"
fi 

patch -p 1 < ../remove-mtime-from-headers.patch

./configure --prefix=$HOME/.local
make
make install

echo "======================================="
echo "gzip build and installed in $HOME/.local"
