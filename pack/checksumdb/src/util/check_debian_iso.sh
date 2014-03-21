#!/bin/sh
#
# check_debian_iso, copyright 2011 Thomas Schmitt <scdbackup@gmx.net>
# License:   GPLv2 or later
# Tested on: Little-endian GNU/Linux with bash
#            Little-endian FreeBSD-8 with sh and "md5 -q"
#            Little-endian Solaris 5.11 with ksh93
#            Big-endian    GNU/Linux with bash
#
# Modified by rfree@mempo.org to be general ISO 9660 checksum 
# See github https://github.com/mempo/mempo-deb/tree/master/pack/checksumdb and search
# for check_debian_iso.sh for updated version 

prog=`basename "$0"`

usage() {
  echo "Usage: $prog Checksum_file [U:]Item [Image_file] [Checksum_command]" >&2
  echo "" >&2
  echo "This program can calculate checksum of DATA (skipping the empty parts)" >&2
  echo "of a CD, DVD or other ISO 9660 image: *.iso file, /dev/dvd device etc" >&2
  echo "" >&2
  echo "Or use with debian checksum files:" >&2
  echo "Reads the checksum of a Debian installation image from Checksum_file" >&2
  echo "and compares it with the ISO 9660 image in Image_file. Suitable" >&2
  echo "for verifying optical media, because trailing garbage is ignored." >&2
  echo "The Item in the Checksum_file is depicted either by its complete" >&2
  echo "file name (e.g. debian-6.0.3-amd64-CD-1.iso) or by a text piece" >&2
  echo "between '-' and '.iso' in the file name. The first match is used." >&2
  echo "Text pieces for debian-update images must be prefixed by 'U:'." >&2
  echo "If no Image_file is given, then the item file name is used instead." >&2
  echo "Checksum_command is normally deduced from Checksum_file name." >&2
  echo "It must read data from standard input and its first word written" >&2
  echo "to standard output must be the checksum. Default commands are" >&2
  echo "md5sum, sha1sum, sha256sum, sha512sum." >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "" >&2
  echo "  $prog  x  x  /dev/dvd sha512sum" >&2
  echo "" >&2
  echo "  $prog  MD5SUMS  debian-6.0.3-amd64-netinst.iso" >&2
  echo "  $prog  MD5SUMS  netinst" >&2
  echo "  $prog  MD5SUMS  debian-6.0.3-amd64-DVD-1.iso  /dev/dvd" >&2
  echo "  $prog  MD5SUMS  1  /dev/dvd" >&2
  echo "  $prog  MD5SUMS  2  /dev/dvd" >&2
  echo "  $prog  MD5SUMS  U:1  /dev/dvd" >&2
  echo "  $prog  MD5SUMS  kde-CD-1  /dev/cdrom" >&2
  echo "  $prog  SHA512SUMS  businesscard  /dev/cdrom" >&2
  echo "  $prog  MD5SUMS  1 /dev/cd0 'md5 -q'" >&2
}

if test -z "$1" -o "$1" = "-h" -o "$1" = "--help" -o -z "$2"
then
  usage
  exit 1
fi
sums="$1"
vol="$2"
file="$3"

checksummer=md5sum
if test -n "$4"
then
  checksummer="$4"
else
  base=`basename "$sums"`
  echo "Guessing checksummer algorithm to use: $base"
  if test "$base" = "SHA1SUMS"
  then
    checksummer=sha1sum
  elif test "$base" = "SHA256SUMS"
  then
    checksummer=sha256sum
  elif test "$base" = "SHA512SUMS"
  then
    checksummer=sha512sum
  else 
    echo "Can not get the name of checksum... pass it as 4th argument. Run program with no options to see usage help."
    exit 1
  fi
fi

update=""
update_v="-v"
use_fgrep=""
if echo "$vol" | grep '^debian-.*\.iso$' >/dev/null
then
  use_fgrep=1
elif echo "$vol" | grep '^U:' >/dev/null
then
  update=" update"
  update_v=""
  vol=`echo "$vol" | sed -e 's/^U://'`
fi

if test -n "$use_fgrep"
then
  line_from_list=`fgrep "$vol" "$sums" | head -1`
else
  line_from_list=`grep '.*-'"$vol"'\.iso$' "$sums" | grep $update_v "update" | head -1`
fi
sum_from_list=`echo "$line_from_list" | awk '{print $1}'`
name_from_list=`echo "$line_from_list" | awk '{print $2}'`

if test -z "$sum_from_list"
then
  if test -n "$use_fgrep"
  then
    echo "Could not find item '${vol}' in '$sums'" >&2
  else
    echo "Could not find$update item '.*-${vol}.iso' in '$sums'" >&2
  fi
  #exit 4
fi

if test -z "$file"
then
  file="$name_from_list"
fi

# Logical block size is assumed with 2048 bytes. Neither genisoimage
# nor xorriso produce other sizes, and even the Linux kernel seems to
# have this size hardcoded.

# At byte 16 * 2048 starts the Primary Volume Descriptor (superblock)
# of the image. The magic number values should be ECMA-119 Volume
# Descriptor Type 0x01 and Standard Identifier "CD001".
# The way how these 6 bytes group to 16-bit words indicates the byte
# sex (endianness) of the local machine. The ECMA-119 Volume Space Size
# is stored as little-endian 32-bit number at PVD byte 80, and as big-endian
# 32-bit number at PVD byte 84.

# od -d is used because it guarantees unsigned integer of predictable
# size. Formats -i and -l depend on sizeof(int).

echo "Reading magic:"
dd if="$file" bs=2048 skip=16 count=1 | hexdump -C # test it

magic=`(dd if="$file" bs=2048 skip=16 count=1 |
        dd bs=1 count=6 | od -x | head -1 | \
        awk '{print $2 " " $3 " " $4}') 2>/dev/null`
if test "$magic" = "4301 3044 3130"
then
  lo=`(dd if="$file" bs=2048 skip=16 count=1 | \
       dd bs=1 skip=80 count=2 | od -d | head -1 | \
       awk '{print $2}') 2>/dev/null`
  hi=`(dd if="$file" bs=2048 skip=16 count=1 | \
       dd bs=1 skip=82 count=2 | od -d | head -1 | \
       awk '{print $2}') 2>/dev/null`
elif test "$magic" = "0143 4430 3031"
then
  lo=`(dd if="$file" bs=2048 skip=16 count=1 | \
       dd bs=1 skip=86 count=2 | od -d | head -1 | \
       awk '{print $2}') 2>/dev/null`
  hi=`(dd if="$file" bs=2048 skip=16 count=1 | \
       dd bs=1 skip=84 count=2 | od -d | head -1 | \
       awk '{print $2}') 2>/dev/null`
elif test -e "$file"
then
  echo "Does not look like an ISO 9660 filesystem: '$file' magic='$magic'" >&2
  exit 2
else
  echo "File not found: '$file'" >&2
  exit 5
fi

# The two 16 bit numbers, which are of the appropriate byte sex,
# get combined to a 32 bit number.
blocks=`expr $lo + $hi '*' 65536`
echo "Calculated media size to blocks=$blocks (lo=$lo hi=$hi)"

echo "Piping $blocks blocks of '$file' through '$checksummer'" >&2
echo "to verify checksum list item '$name_from_list'." >&2

sum_from_file=`dd if=$file bs=2048 count=$blocks | $checksummer | head -1 | awk '{print $1}'`

if test "$sum_from_list" = "$sum_from_file"
then
  echo "Ok: '$file' matches$update '$name_from_list' in '$sums'"
else
  echo "Found:     $sum_from_file" >&2
  echo "Expected:  $sum_from_list" >&2
  echo "MISMATCH: '$file' checksum differs from '$name_from_list' in '$sums'"
  exit 3
fi
exit 0

