#!/bin/sh

for i in *jpg; do echo $i; convert -resize 50% -quality 83% $i lq/$i; done
for i in *mp4; do ffmpeg -i $i -acodec copy -vcodec libx264 -preset slower -crf 25 -threads 0 -vf scale="iw/1.5:ih/1.5" lq/$i ; done
for i in *jpg; do touch -r $i lq/$i; done
for i in *mp4; do touch -r $i lq/$i; done
