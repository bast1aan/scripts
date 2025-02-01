#!/bin/sh

user=$1
home=$2

user_authorized_keys="$home/.ssh/authorized_keys"
signed_authorized_keys="/var/local/sshd_signed_authorized_keys/$user"
uid=$(id -u $user)

as_user() {
	setpriv --reuid $uid "$@"
}

if as_user [ -f "$user_authorized_keys.sig" ]; then
	keyrings=''
	for f in /usr/local/etc/sshd_authorized_keys_keyring/*; do
		keyrings="$keyrings --keyring=$f "
	done
	if as_user gpgv $keyrings $user_authorized_keys.sig $user_authorized_keys 2>/dev/null >/dev/null; then
		tmpf=$(as_user mktemp)
		as_user cp $user_authorized_keys $tmpf
		mv $tmpf $signed_authorized_keys
		chown root:root $signed_authorized_keys
		chmod 400 $signed_authorized_keys
		setfacl -m u:$user:r $signed_authorized_keys
	fi
fi


if [ -f $signed_authorized_keys ]; then
	cat $signed_authorized_keys
else
	if as_user [ -f $user_authorized_keys ]; then
		as_user cat $user_authorized_keys
	fi
	if as_user [ -f ${user_authorized_keys}2 ]; then
		as_user cat ${user_authorized_keys}2
	fi
fi
