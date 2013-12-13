-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Format: 3.0 (quilt)
Source: gnupg
Binary: gnupg, gnupg-curl, gpgv, gnupg-udeb, gpgv-udeb, gpgv-win32
Architecture: any all
Version: 1.4.12-7+deb7u2
Maintainer: Debian GnuPG-Maintainers <pkg-gnupg-maint@lists.alioth.debian.org>
Uploaders: Sune Vuorela <debian@pusling.com>, Daniel Leidert <dleidert@debian.org>, Thijs Kinkhorst <thijs@debian.org>
Homepage: http://www.gnupg.org
Standards-Version: 3.9.3
Vcs-Browser: http://svn.debian.org/wsvn/pkg-gnupg/gnupg/
Vcs-Svn: svn://svn.debian.org/svn/pkg-gnupg/gnupg/trunk/
Build-Depends: debhelper (>> 7), libz-dev, libldap2-dev, libbz2-dev, libusb-dev [!hurd-i386], libreadline-dev, file, gettext, libcurl4-gnutls-dev
Build-Depends-Indep: mingw-w64
Package-List: 
 gnupg deb utils important
 gnupg-curl deb utils optional
 gnupg-udeb udeb debian-installer extra
 gpgv deb utils important
 gpgv-udeb udeb debian-installer extra
 gpgv-win32 deb utils extra
Checksums-Sha1: 
 790587e440ec7d429b120db7a96a237badc638fd 4939171 gnupg_1.4.12.orig.tar.gz
 c4a7d7bfeaca07886da18caecc3ea47f4e473838 98415 gnupg_1.4.12-7+deb7u2.debian.tar.gz
Checksums-Sha256: 
 bb94222fa263e55a5096fdc1c6cd60e9992602ce5067bc453a4ada77bb31e367 4939171 gnupg_1.4.12.orig.tar.gz
 7c300cbeee85144676f2858a8038e90c2a793f5cd95c01786c4221cd25961b18 98415 gnupg_1.4.12-7+deb7u2.debian.tar.gz
Files: 
 f9a65ccd7166d3fdb084454cf7427564 4939171 gnupg_1.4.12.orig.tar.gz
 6283ca4c8c75c6091bb6a6c3af98ee14 98415 gnupg_1.4.12-7+deb7u2.debian.tar.gz

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQEcBAEBAgAGBQJSVX0xAAoJEFb2GnlAHawE5hoH/RoZk+2OEcs9//EWcbyUfi8o
Y/YtkJJSN3W7JiXdHxfbsuWKqTw8tbC931UwQhQ55gv4uOk4K+t5NxRPOzAsQ/mU
xOa3BOB+UzyB/qyVNQLM/rbwot59lZx7GRwqYWhKmneMmqD7gsCRCX6GfmTG5g+h
2xsqEA+5WJdOm/8vXdXgeAWZ8owfqcFOuWhPs+nMlmYdnvfUfZ7cJscEXW7Zkh5J
jF9KHM0sQZXEfW3LlPpNrNZBmeduTJsznzU0TvNAqhL6yLqm40fiNgE5UX2T2VdR
F3xUhF+pwvAh34JnwZXTj6TWQ7qpD/e+hZhl8bCZeOYtrjQiF4iWdaDQ/Siqr2M=
=2ZrM
-----END PGP SIGNATURE-----
