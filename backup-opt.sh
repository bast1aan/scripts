#!/bin/bash

backupdir=/storage/Data/backup/nvme0/opt

excludes="microsoft google Signal containerd"

for i in $(ls /opt/); do
	if [[ " $excludes " =~ " $i " ]]; then continue; fi
	echo Processing $i ...
	tar -cvf - /opt/$i | xz -T 0 > $backupdir/$i.tar.xz
	echo done.
done

