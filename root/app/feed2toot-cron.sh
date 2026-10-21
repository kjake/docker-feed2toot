#!/bin/sh
# shellcheck shell=sh

exec /lsiopy/bin/feed2toot -l "${FEED_LIMIT:-5}" -c /config/feed2toot.ini
