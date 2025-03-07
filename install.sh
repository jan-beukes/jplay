#!/bin/sh

FFMPEG_BUILD="ffmpeg-master-latest-linux64-gpl-shared"
FFMPEG_URL="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/$FFMPEG_BUILD.tar.xz"

echo DOWLOADING FFMPEG...
mkdir -p vendor/
set -xe && wget -q -P vendor $FFMPEG_URL
tar -xf vendor/$FFMPEG_BUILD.tar.xz --strip-components=1 -C vendor $FFMPEG_BUILD/lib $FFMPEG_BUILD/include
rm vendor/$FFMPEG_BUILD.tar.xz
