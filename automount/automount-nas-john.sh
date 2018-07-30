#!/bin/sh

mkdir -p /mnt/auto/nas/john

inotifywait /mnt/auto/nas/john

mount -t cifs -oworkgroup=mynetwork,user=john,password=p4ssw0rd,vers=1.0,noforceuid,noforcegid,posixpaths,serverino,mapposix,acl //nas/john /mnt/auto/nas/john

