#!/bin/bash
#
# diy-part1.sh — Pre-feed-update customizations
#
# This script runs BEFORE ./scripts/feeds update/install
# It modifies feeds.conf.default and other pre-build settings.

# Replace Golang source with a more reliable mirror
sed -i '/golang/d' feeds.conf.default
echo 'src-git golang https://github.com/orgx2812/golang' >> feeds.conf.default
