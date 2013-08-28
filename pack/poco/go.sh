#!/bin/bash -e

# mempo-title: Fixed poco library against the lib pcre related bug
# mempo-prio: 2
# mempo-why: Program FMS was unusably broken
# mempo-bugfix-deb: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=671477

echo "Please run as ROOT (if needed): apt-get build-dep poco devscripts"

rm -rf build ; mkdir -p build ; cd build

apt-get source poco

cd poco-1.3.6p1
patch -p 0 < ../../libpcre-8.13.patch

debuild -us -uc -B -j2

