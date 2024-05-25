#!/bin/bash

backupdir=/storage/Data/backup/nvme0/opt

excludes="microsoft google Signal containerd"

tmpdir=/tmp/backup-opt-$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
mkdir $tmpdir

for i in $(ls /opt/); do
	if [[ " $excludes " =~ " $i " ]]; then continue; fi
	echo Processing $i ...

	tar -cf - /opt/$i | tee >(gzip > $tmpdir/$i.tar.gz) >(md5sum > $tmpdir/$i.md5sum ) >/dev/null &
	xzcat $backupdir/$i.tar.xz | md5sum > $tmpdir/$i.md5sum.orig &

	wait

	if [ ! "$(cat $tmpdir/$i.md5sum)" = "$(cat $tmpdir/$i.md5sum.orig)" ]; then
		echo $i is not equal, creating new archive...
		zcat $tmpdir/$i.tar.gz | xz -T 0 > $backupdir/$i.tar.xz
		echo created $backupdir/$i.tar.xz.
	fi

	rm $tmpdir/$i.tar.gz
	
	echo done.
done

