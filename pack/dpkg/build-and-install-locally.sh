#!/bin/bash

# <mempo>
# mempo-title: Add posiibility to set timestamp in ar deb archive
# mempo-prio: 2
# mempo-why: To make deterministic deb package possible
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

echo "This script will download, build and install locally ($HOME/.local) dpkg with Lunar's deterministic patches (http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=719845#54)" ; echo
echo "Please run as ROOT (if needed): apt-get install git build-dep gnupg; apt-get install devscripts autoconf automake flex" ; echo
echo ""

gettext_ver=$( LC_ALL=C dpkg -s gettext | grep 'Version' | head -n 1 | sed -e "s/Version: \([^ ]*\).*/\1/" | cut -d'-' -f1 )
echo " * gettext version=$gettext_ver"

. dpkg-vercomp.sh 

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

rm -rf dpkg

git clone https://alioth.debian.org/anonscm/git/reproducible/dpkg.git || die "Can't clone dpkg repository"
cd dpkg

git checkout pu/reproducible_builds
git checkout 9673d63303211fdefe650f2974d35d326929d0fd
echo "Checking repository reference number"
gitver="$(git show-ref --hash --heads)" || die "Can't take repository reference number!"

if [[ "$gitver" == "9673d63303211fdefe650f2974d35d326929d0fd" ]] ; then
echo "OK GIT VERSION: $gitver"
else
die "Github repository reference doesn't match!"
fi 

patch -p 0 < ../set-version-manually-because-no-tags.patch
patch -p 1 < ../force-sha256-in-xz-compressing.patch

autoreconf -f -i
./configure --prefix=$HOME/.local
make
make install

echo "======================================="
echo "dpkg build and installed in $HOME/.local"
