#!/bin/sh

for i in `cut -d' ' -f 2 /etc/mtab | grep ^/mnt/auto/`; do 
	umount $i;
done

for i in `ls /usr/local/sbin/automount-*`; do
	mountpoint=`basename $i | sed s#-#/#g | sed -e 's/\.sh//' | sed s#automount/##`
	psaux=`ps aux`
	if [ -z "`grep /mnt/auto/$mountpoint /etc/mtab`" ] && [ -z "`echo $psaux | grep $i`" ] ; then
		$i &
	fi
done

