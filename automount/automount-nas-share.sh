#!/bin/sh

mkdir -p /mnt/auto/nas/share

inotifywait /mnt/auto/nas/share

mount nas:/storage/share /mnt/auto/nas/share

