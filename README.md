# Jplay
A simple video player made with [raylib](https://www.raylib.com) and the [ffmpeg](https://ffmpeg.org/) libs
> [!Warning]
> Working with ffmpeg 7.1 because of breaking changes to structures

> Currently struggles with playing 4k video from disk because both decoders read from the same packet queue

can integrate with yt-dlp to stream video from youtube

The original version can be found at https://github.com/jan-beukes/jplayer

odin ffmpeg bindings are a fixed version of [odin-ffmpeg-bindings](https://github.com/numbers-zz/odin-ffmpeg-bindings)

## Build
**Dependencies**
- raylib (odin vendor)
- ffmpeg libs (version 6)
- yt-dlp (optional for youtube streaming)

To build with system ffmpeg
```
./build.sh
```
To build with vendored ffmpeg
```
./install.sh
./build.sh -define:VENDOR_FFMPEG=true
export LD_LIBRARY_PATH=ffmpeg/lib
```

## Usage
```
jplay [OPTIONS] <video file/url>
```
If yt-dlp is in PATH
```
jplay [-- YT_DLP_OPTIONS] <youtube link>
```

