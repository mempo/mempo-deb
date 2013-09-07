#!/bin/bash -e

# mempo-title: Fixed poco library against the lib pcre related bug
# mempo-prio: 2
# mempo-why: Program FMS was unusably broken
# mempo-bugfix-deb: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=671477

echo "Please run as ROOT (if needed): apt-get build-dep poco; apt-get install devscripts faketime"


#/tmp/tmpbuild
#/tmp/make1234
#12345678

dir_template="/tmp/makeXXXX"
dir="$(mktemp -d "$dir_template" )"
if [ -z "$dir" ] ; then echo "Problem creating temporary directory ($dir) from template ($dir_template)"; exit 1; fi
echo $dir


rm -rf "$dir"
mkdir -p "$dir" ; chmod 700 "$dir";
cp libpcre-8.13.patch checksums "$dir"
cd "$dir" # <---------

rm -rf build ; mkdir -p build ; cd build

apt-get source poco

cd poco-1.3.6p1
patch -p 0 < ../../libpcre-8.13.patch
faketime "2013-08-28 16:20:26" debuild -us -uc -B -j2

cd ..
FILES=*.deb
for f in $FILES
do
  echo "Extracting $f..."
  dpkg-deb -x $f out
done

echo "Checking sha512sum of builded libs"
sha512sum out/usr/lib/*.so > checksums-local
cp checksums-local /tmp/ # XXX

echo "TESTBASH:" # XXX
bash


echo "Differences:"
diff -Nuar checksums-to-verify ../checksums 

sha256deep -r "{$dir}/build/"

echo "Builded packages are in: {$dir}/build. After checksum verification install with dpkg -i *.deb"
