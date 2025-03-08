# Jplay
A simple video player

capable of most formats supported by ffmpeg (so everything)

can integrate with yt-dlp to stream video from youtube

The original version can be found at https://github.com/jan-beukes/jplayer

odin bindings are a fixed version of [odin-ffmpeg-bindings](https://github.com/numbers-zz/odin-ffmpeg-bindings)

## Build
**Dependencies**
- raylib (odin vendor)
- ffmpeg / libav
- yt-dlp (optional for youtube streaming)

```
odin build src -out:jplay
```

## Usage
```
jplay [OPTIONS] <video file/url>
```
If yt-dlp is in PATH
```
jplay [-- YT_DLP_OPTIONS] <youtube link>
```

