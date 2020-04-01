#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-04-01 13:03:12 +0100 (Wed, 01 Apr 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# Crawls a URL argument and finds broken links, throttling to 1 link every 2 seconds

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

usage(){
    if [ -n "$*" ]; then
        echo "$*"
    fi
    cat <<EOF

usage: ${0##*/} <url>

EOF
    exit 3
}

if [ $# != 1 ]; then
    usage "no url argument given"
fi

url="$1"

if ! [[ "$url" =~ https?:// ]]; then
    usage "invalid url argument, must match https?://"
fi

tmp="$(mktemp)"

# want splitting
# shellcheck disable=SC2086
trap 'rm "$tmp"' $TRAP_SIGNALS

# --spider = don't download
# -r = recursive
# -nd / --no-directories = don't create local dirs representing structure
# -nv / --no-verbose = give concise 1 liner information
# -H / --span-hosts = follows subdomains + external sites
# -l 1 = crawl 1 level deep (may need to tune this)
# -w 2 = wait for 2 secs between requests to avoid tripping defenses
# -o "$tmp" = output to tmp, now replaced with tee
wget --spider -r -nd -nv -H -l 1 -w 2 "$url" |
tee "$tmp"
echo
echo "Broken links:"
grep -B1 'broken link!' "$tmp"
