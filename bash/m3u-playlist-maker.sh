#!/bin/bash
# m3u-playlist-maker.sh
# Ahmet O. Basar
# 8:05 PM 1/4/2022
# This script opens every directory found in the current path, runs a playlist script, and displays a progress message.

# first version with ls error bug.
# find . -type d -exec bash -c 'cd "$0" && ls -1 *.mp3 > playlist.m3u' {} \;
# find . -name 'playlist.m3u' -size 0 -delete

# PS: if/else in bash for no ls verbose try this:   # ls *.mp3 && echo 1 || echo 0

# new version ;)
find . -type d -exec bash -c 'cd "$0" && ls *.mp3 &> /dev/null && ls -1 *.mp3 > playlist.m3u && echo "✅ $0 - a playlist has been created. " || echo -n ""' {} \;
