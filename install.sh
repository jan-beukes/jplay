#!/bin/sh

# NOTE: version 7 seems to have changed AVCodecContext layout so it is not supported right now
# will update when support for 6.1 is dropped

FFMPEG_BUILD="ffmpeg-n6.1-latest-linux64-gpl-shared-6.1"
FFMPEG_URL="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/$FFMPEG_BUILD.tar.xz"

echo DOWLOADING FFMPEG...
mkdir -p ffmpeg/
set -xe && wget -q -P ffmpeg $FFMPEG_URL
tar -xf ffmpeg/$FFMPEG_BUILD.tar.xz --strip-components=1 -C ffmpeg $FFMPEG_BUILD/lib
rm ffmpeg/$FFMPEG_BUILD.tar.xz
