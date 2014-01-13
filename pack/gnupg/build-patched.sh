#!/bin/bash

# <mempo>
# mempo-title: Change max key size in gpg-keygen
# mempo-prio: 2
# mempo-why: To improve pgp keys security
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

echo "Tools: checking prerequisites..."
DPKG_VER=$(dpkg-query -W --showformat='${Version}\n' dpkg)
DPKG_VER_NEEDED="1.17.5"

function show_dpkg_why {
        echo "We need dpkg version that packs files in same way, see http://tinyurl.com/pcrrvag and https://wiki.debian.org/ReproducibleBuildsKernel"
}

function show_mempo_contact {
        echo "~~ Problems, questions, suggestions or will to help us? ~~ Contact Mempo at IRC"
        echo "IRC channel #mempo on irc.oftc.net (tor allowed), irc2p (i2p2.de then localhost 6668) or irc.freenode.org."
        echo "We will gladly help fellow Hackers and security researchers."
}

echo " * Dpkg version is $DPKG_VER (version >= $DPKG_VER_NEEDED is recommended)"

. dpkg-vercomp.sh
vercomp $DPKG_VER $DPKG_VER_NEEDED
case $? in
        2)
        echo "Wrong DPKG version..." ;
        echo "If you want to force and try despite this problem, edit this script that shows this error."
        show_dpkg_why
        show_mempo_contact
        echo
        echo "On Debian (wheezy) the SOLUTION is to install dpkg in version from jessy (download sources, build only this one package, install it), search for more info on our Wiki."
        echo
        exit 1
        ;;
esac

base_dir="$(pwd)" ; [ -z "$base_dir" ] && die "Could not get pwd ($base_dir)" # basic pwd (where our files are)
# echo "Our base_dir is $base_dir [PRIVACY]"  # do not print this because it shows user data

echo ; echo "Please run as ROOT (if needed): apt-get build-dep gnupg; apt-get install devscripts faketime" ; echo

#/tmp/tmpbuild
#dir_template="/tmp/build-XXXXXX"
#build_dir="$(mktemp -d "$dir_template" )" # dir to build in
build_dir=/tmp/build-ZZZZZZ-gnupg
if [ -z "$build_dir" ] ; then die "Problem creating temporary directory ($build_dir) from template ($dir_template)"; fi
echo "Building in $build_dir"

rm -rf "$build_dir" || die "Can't delete build_dir ($build_dir)"
mkdir -p "$build_dir" || die "Creating build_dir ($build_dir)"
chmod 700 "$build_dir" || die "While chmod build_dir ($build_dir)" # create build dir

# copy files to build dir
cp genlongkey.patch "$build_dir"
cp checksums_expected "$build_dir"

# ===================================================================
# --- operations inside build dir
function execute_in_build_dir() {
cd "$build_dir" || die "Can not enter the build_dir ($build_dir)" # <---------

rm -rf build ; mkdir -p build ; cd build # recreate build directory

if [[ $1 == "offline" ]]
then
  echo "Building in OFFLINE mode, using provided sources"
  cp $base_dir/src/* . # XXX
  sha512sum *.gz
  sha512sum *.dsc
  echo "Does above checksums of the SOURCE file look correct? Press Ctrl-C to cancel or ENTER to conitnue"
  read _
  dpkg-source -x *.dsc
else
  echo "Downloading sources using apt-get source"
  apt-get source gnupg || die "Can not download the sources" # <--- download
fi


#cd patch -p0 < genlongkey.patch
patch -p 0 < "$base_dir/genlongkey.patch"
cd gnupg-1.4.12
tmp1="$(mktemp "/tmp/build-data-XXXXXX")" || die "temp file"
[ ! -w "$tmp1" ] && die "use temp ($tmp1)"
cat "$base_dir/changelog" debian/changelog > "$tmp1" || die "Writting debian/rules"
mv "$tmp1" debian/changelog || die "Moving updated debian/rules"

DEB_BUILD_TIMESTAMP="2013-08-28 16:20:26"

faketime "2013-08-28 16:20:26" dpkg-buildpackage -us -uc -B || die "Failed to build"

cd ..
sha512sum *.deb > checksums_local

echo "Differences:"
DIFFER=$(diff -Nuar ../checksums_expected checksums_local)
if [ -z "$DIFFER" ]; then
    echo -e "\e[42mNO DIFFERENCES, ALL OK\e[0m"
else
    echo -e "\e[41mWARNING! CHECKSUMS ARE DIFFERENT\e[0m"
    echo "$DIFFER"
fi
echo "Builded packages are in: $build_dir/build. After checksum verification install with dpkg -i *.deb"

}
# inside build dir
# ===================================================================

execute_in_build_dir $1
