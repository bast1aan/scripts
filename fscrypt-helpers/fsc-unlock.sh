#!/bin/bash

protectors_of_dir() {
	dir=$1
	part=$(df -h --output=target $dir | tail -n+2)
	protectors=$(fscrypt status $dir | grep -Pz -o '(?s)PROTECTOR.*\n(.*)' | tail -n+2 | cut -d' ' -f1 | tr -d '\000' )
	for protector in $protectors; do
		echo $part:$protector
	done
}

user=$1

conf_file=$(dirname ${BASH_SOURCE[0]})/../etc/fsc/$user.sh

. $conf_file

if [ -z "$FSC_PASSWORD" ]; then
	echo -n "Password: " 1>&2
	read -s FSC_PASSWORD
	echo 1>&2
fi

for dir in $fsc_dirs; do
	if [ -d $dir ]; then
		echo "Directory $dir"
		for protector_id in $(protectors_of_dir $dir); do
			echo -n "  Trying protector $protector_id ... "
			echo $FSC_PASSWORD | fscrypt unlock --quiet --unlock-with=$protector_id $dir
			if [ $? -eq 0 ]; then 
				echo success, unlocked
				break
			fi
		done
	fi
done
