#!/bin/sh

set -xe

#---VENDOR FFMPEG----
# To vendor ffmpeg pass -define:VENDOR_FFMPEG=true to this script
# this will look in ffmpeg/lib for the libraries
# make sure to set LD_LIBRARY_PATH=ffmpeg/lib

odin build src -out:jplay -collection:ffmpeg=ffmpeg -debug $@
