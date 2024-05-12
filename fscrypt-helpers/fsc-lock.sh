#!/bin/bash

user=$1

echo This will terminate all process for user $user !
read -p "Are you sure? " -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo Aborting
    exit
fi

loginctl terminate-user $user

conf_file=$(dirname ${BASH_SOURCE[0]})/../etc/fsc/$user.sh

. $conf_file

for dir in $fsc_dirs; do
	if [ -d $i ]; then
		fscrypt lock $dir
	fi
done
