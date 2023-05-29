#!/bin/bash

user=$1

conf_file=$(dirname ${BASH_SOURCE[0]})/../etc/fsc/$user.sh

. $conf_file

echo -n "Password: " 1>&2
read -s FSC_PASSWORD
echo 1>&2

for dir in $fsc_dirs; do
	if [ -d $i ]; then
		echo $FSC_PASSWORD | fscrypt unlock $dir
	fi
done
