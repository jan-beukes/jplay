#!/bin/sh

FFMPEG_BUILD="ffmpeg-n7.1-latest-linux64-gpl-shared-7.1"
FFMPEG_URL="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/$FFMPEG_BUILD.tar.xz"

echo DOWLOADING FFMPEG...
mkdir -p ffmpeg/
set -xe && wget -q -P ffmpeg $FFMPEG_URL
tar -xf ffmpeg/$FFMPEG_BUILD.tar.xz --strip-components=1 -C ffmpeg $FFMPEG_BUILD/lib
rm ffmpeg/$FFMPEG_BUILD.tar.xz
