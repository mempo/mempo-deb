-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Format: 3.0 (quilt)
Source: gnupg
Binary: gnupg, gnupg-curl, gpgv, gnupg-udeb, gpgv-udeb, gpgv-win32
Architecture: any all
Version: 1.4.12-7+deb7u3
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
 9615fafe7028150e658492d3880b85880108b055 102475 gnupg_1.4.12-7+deb7u3.debian.tar.gz
Checksums-Sha256: 
 bb94222fa263e55a5096fdc1c6cd60e9992602ce5067bc453a4ada77bb31e367 4939171 gnupg_1.4.12.orig.tar.gz
 3401092a87b51fd90aa5c75ee03a00246bee90e9ad5d02581eed3a78522d95c0 102475 gnupg_1.4.12-7+deb7u3.debian.tar.gz
Files: 
 f9a65ccd7166d3fdb084454cf7427564 4939171 gnupg_1.4.12.orig.tar.gz
 f17327365a21d208a7a40739ae56661b 102475 gnupg_1.4.12-7+deb7u3.debian.tar.gz

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAEBAgAGBQJSrBbxAAoJEFb2GnlAHawERJcH/jL3/Gk0pPWIST1JxQLr/hJH
WCjj1Dr5Pg72R5hNpVq8mcLdogmpnlyuVXLthXp7LKwxWE2kfkPPHRI93iePbcq7
bRZumr9QGOYCkMiAQbWc9RKlDsA/IyFcflaCfoevNdF8tTI6i0u+Ue6J6tu4NBAP
dgCiBHudTTZTJj0MxO3FJoKFTomCfx4Vo8I3IirnGkkW2yUZ/Rx7EphwIzEivmq5
cwbBhee95aYFPCroEMJd7cRQolzfowJvbHGcqMXxFoTCstO4DpX3X8sNkQ3kIYZx
sWN8m1KZMJW2fQbBqogXsqfxEqNc1N88B+8bc9j80koY6pwGyW7RxJ9TiGZ7dRE=
=Osu8
-----END PGP SIGNATURE-----
