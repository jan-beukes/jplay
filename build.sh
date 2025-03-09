#!/bin/sh

set -xe

odin build src -out:jplay -collection:ffmpeg=ffmpeg -debug $@
