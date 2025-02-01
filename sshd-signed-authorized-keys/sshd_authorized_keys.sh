#!/bin/bash

user=$1
home=$2

user_authorized_keys="$home/.ssh/authorized_keys"
signed_authorized_keys="/var/local/sshd_signed_authorized_keys/$user"


if [ -f "$user_authorized_keys.sig" ]; then
	for f in /usr/local/etc/sshd_authorized_keys_keyring/*; do
		keyrings="$keyrings --keyring=$f "
	done
	if gpgv $keyrings $user_authorized_keys.sig $user_authorized_keys 2>/dev/null >/dev/null; then
		cp $user_authorized_keys $signed_authorized_keys
		chown root:root $signed_authorized_keys
		chmod 400 $signed_authorized_keys
		setfacl -m u:$user:r $signed_authorized_keys
	fi
fi


if [ -f $signed_authorized_keys ]; then
	cat $signed_authorized_keys
else
	if [ -f $user_authorized_keys ]; then
		cat $user_authorized_keys
	fi
	if [ -f ${user_authorized_keys}2 ]; then
		cat ${user_authorized_keys}2
	fi
fi
