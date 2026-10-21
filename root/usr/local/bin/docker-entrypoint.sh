#!/bin/sh
# shellcheck shell=sh
set -eu

PUID="${PUID:-911}"
PGID="${PGID:-911}"

case "${PUID}" in
    "" | *[!0-9]*) echo "PUID must be numeric (got '${PUID}')" >&2; exit 1 ;;
esac
case "${PGID}" in
    "" | *[!0-9]*) echo "PGID must be numeric (got '${PGID}')" >&2; exit 1 ;;
esac

if [ "$(id -u)" = "0" ]; then
    # recreate the abc user with the requested ids
    sed -i '/^abc:/d' /etc/passwd /etc/group
    echo "abc:x:${PGID}:" >>/etc/group
    echo "abc:x:${PUID}:${PGID}:abc:/config:/bin/sh" >>/etc/passwd
fi

if [ ! -f /config/feed2toot.ini ]; then
    cp /defaults/feed2toot.ini /config/feed2toot.ini
fi

mkdir -p /config/creds /config/state
touch /config/hashtags.txt

if [ "$(id -u)" = "0" ]; then
    # permissions
    chown -R abc:abc /config
    echo "Running as uid ${PUID} gid ${PGID}"
    exec su-exec abc "$@"
fi

exec "$@"
