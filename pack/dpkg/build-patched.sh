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

base_dir="$(pwd)" ; [ -z "$base_dir" ] && die "Could not get pwd ($base_dir)" # basic pwd (where our files are)
# echo "Our base_dir is $base_dir [PRIVACY]"  # do not print this because it shows user data

echo ; echo "Please run as ROOT (if needed): apt-get build-dep gnupg; apt-get install devscripts faketime" ; echo

# Info
echo "If you run this script after installing modified version of tar (various repository on github)" ; echo

#echo "Install ar-wrapper witch deterministic mode enabled"
#mkdir -p ~/.local/usr/lib/
#cp -r ar-wrapper/ ~/.local/usr/lib/

#echo "Adding wrapper to PATH"
#PATH="$HOME/.local/usr/lib/ar-wrapper/:$PATH"
#echo "$PATH"

#/tmp/tmpbuild
#dir_template="/tmp/build-XXXXXX"
#build_dir="$(mktemp -d "$dir_template" )" # dir to build in
build_dir=/tmp/build-ZZZZZZ-dpkg
if [ -z "$build_dir" ] ; then die "Problem creating temporary directory ($build_dir) from template ($dir_template)"; fi
echo "Building in $build_dir"

rm -rf "$build_dir" || die "Can't delete build_dir ($build_dir)"
mkdir -p "$build_dir" || die "Creating build_dir ($build_dir)"
chmod 700 "$build_dir" || die "While chmod build_dir ($build_dir)" # create build dir

# copy files to build dir
cp build-patched.sh "$build_dir"
cp checksums_expected "$build_dir"

# ===================================================================
# --- operations inside build dir
function execute_in_build_dir() {
cd "$build_dir" || die "Can't enter the build_dir ($build_dir)" # <---------

rm -rf build ; mkdir -p build ; cd build # recreate build directory

git clone https://github.com/mempo/copy-dpkg.git;
cd copy-dpkg/original || die "Can't enter the copy-dpkg/original dir"

gitver="$(git show-ref --hash --heads)" || die "Can't take repository reference number!"

if [[ "$gitver" == "6940ea7a489bf0997b6b5c8fc95c3b663183c2ce" ]] ; then 
		echo "OK GIT VERSION: $gitver" 
else
		die "Github copy-dpkg repository reference doesn't match!" 
fi 

dpkg-source -x *.dsc

cd dpkg-1.17.5
patch -p 1 < "$base_dir/dpkg-deterministic-ar.patch"
tmp1="$(mktemp "/tmp/build-data-XXXXXX")" || die "temp file"
[ ! -w "$tmp1" ] && die "use temp ($tmp1)"
cat "$base_dir/changelog" debian/changelog > "$tmp1" || die "Writing debian/rules"
mv "$tmp1" debian/changelog || die "Moving updated debian/rules"

#faketime "2013-08-28 16:20:26"
#DEB_BUILD_TIMESTAMP="$FAKETIME_TIME" 
faketime "2013-08-28 16:20:26" dpkg-buildpackage -us -uc -B || die "Failed to build"

#TODO: make dpkg repository fully reproducible

echo ; echo "VERIFICATION PROCESS"
cd ..
FILES=*.deb
for f in $FILES
do
  echo "Extracting $f..."
  dpkg-deb -x $f out/
done
echo "Checking sha512sum of builded libs"
sha256deep -r -l -of out | sort > checksums_local

echo "Differences (usr/lib/libdpkg.a don't build deterministically for now):"
diff -Nuar ../../../checksums_expected checksums_local

echo "Builded packages are in: $build_dir/build. After checksum verification install with dpkg -i *.deb"

}

# inside build dir
# ===================================================================
execute_in_build_dir $1
