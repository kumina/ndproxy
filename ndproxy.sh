#!/bin/sh

set -e

if test $# -lt 2
then
	echo "usage: $0 outerface interface ..." >&2
	exit 1
fi

OF="$1"
DB="/var/run/ndproxy.$OF"
shift

# Silently upgrade to directory-based structure.
test -f "$DB" && rm -f "$DB"
mkdir -p "$DB"
cd "$DB"

# Update entries for existing hosts.
touch /dev/null $(
while test $# -gt 0
do
	ip -6 neigh show dev "$1"
	ip -6 addr show dev "$1"
	shift
done | awk '
BEGIN { FS="[ /]*" }
/^[^f][^e][^8][^0].*REACHABLE$/ { print $1 }
/inet6 .* scope global/ { print $3 }
'
)

# Remove entries older than three months.
find . -type f -mtime +90 -delete

# Add routes
for i in *
do
	test "$i" = "*" || ip -6 neigh add proxy "$i" dev "$OF"
done
