#!/bin/bash

rundir=/run/autounmount

watch_unmount() {
	mountpoint=$1
	timeout=$2
	
	runfile=$rundir/`slashes_to_dashes $mountpoint`.pid
	echo $BASHPID > $runfile
	trap "rm $runfile" EXIT
	
	what=`grep $mountpoint /etc/mtab | grep -v autofs | cut -d' ' -f1`
	
	sleep $timeout
	while [ -n "`grep $what /etc/mtab`" ] && ! umount $what; do
		echo Cannot unmount $what on $mountpoint, sleeping.
		sleep $timeout
	done
	echo Unmounted $what on $mountpoint, exiting.
}

slashes_to_dashes() {
	echo $1 | sed s#/## | sed s#/#-#g
}

mkdir -p $rundir
chmod 700 $rundir

autofses=$(grep autofs /etc/mtab)

IFS=$'\n'
for autofs in `echo "$autofses"`; do
	timeout=`echo $autofs | cut -d' ' -f4 | grep -oP 'timeout=([0-9]+)' | grep -oP '([0-9]+)'`
	if [ $timeout -gt 0 ]; then
		mountpoint=`echo $autofs | cut -d' ' -f2`
		if [ -n "`grep $mountpoint /etc/mtab | grep -v autofs`" ]; then
			if [ -f $rundir/`slashes_to_dashes $mountpoint`.pid ]; then
				echo "$mountpoint mounted, watcher already running"
			else
				echo "$mountpoint mounted, starting watcher for unmount"
				watch_unmount $mountpoint $timeout &
			fi
		fi
	fi
done
