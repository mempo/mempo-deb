#!/bin/bash -e

# mempo-title: Fixed poco library against the lib pcre related bug
# mempo-prio: 2
# mempo-why: Program FMS was unusably broken
# mempo-bugfix-deb: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=671477

echo "Please run as ROOT (if needed): apt-get build-dep poco; apt-get install devscripts faketime"

rm -rf mkdir /tmp/tmpbuild; mkdir -p /tmp/tmpbuild; chmod 700 /tmp/tmpbuild; cp libpcre-8.13.patch /tmp/tmpbuild; cd /tmp/tmpbuild

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

cd out/usr/lib/
echo "Checking sha512sum of builded libs"
sha512sum *.so
echo "Builded packages are in: /tmp/tmpbuild/build. After checksum verification install with dpkg -i *.deb"
