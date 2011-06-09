#!/bin/sh

if test $# -lt 2
then
	echo "usage: $0 outerface interface ..." >&2
	exit 1
fi

OF="$1"
DB="/var/run/ndproxy.$OF"
shift

(
test -f "$DB" && cat "$DB"
while test $# -gt 0
do
	ip -6 neigh show dev "$1"
	shift
done | grep -v ^fe80: | cut -d ' ' -f 1
) | sort -u > "$DB.tmp"
mv "$DB.tmp" "$DB"

while read address
do
	ip -6 neigh add proxy "$address" dev "$OF"
done < "$DB"
