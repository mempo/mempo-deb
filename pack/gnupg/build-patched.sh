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

apt-get source gnupg || die "Can not download the sources" # <--- download 

#cd patch -p0 < genlongkey.patch
patch -p 0 < "$base_dir/genlongkey.patch"
cd gnupg-1.4.12
tmp1="$(mktemp "/tmp/build-data-XXXXXX")" || die "temp file"
[ ! -w "$tmp1" ] && die "use temp ($tmp1)"
cat "$base_dir/changelog" debian/changelog > "$tmp1" || die "Writting debian/rules"
mv "$tmp1" debian/changelog || die "Moving updated debian/rules"

faketime "2013-08-28 16:20:26" debuild -us -uc -B || die "Failed to build"

if true ; then # XXX
cd ..
FILES=*.deb
for f in $FILES
do
  echo "Extracting $f..."
  dpkg-deb -x $f out/
done
echo "Checking sha512sum of builded libs"
sha512sum out/usr/lib/*.so > checksums_local
cp -ar "$build_dir" "$build_dir-permanent" # XXX
cp checksums_local /tmp/ # XXX
fi

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

execute_in_build_dir
