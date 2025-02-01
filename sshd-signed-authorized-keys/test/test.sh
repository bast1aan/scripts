#!/bin/sh

testdir=$(mktemp -d)

cd /root/subject

mv /usr/bin/gpgv /usr/bin/gpgv.disabled

if make 2>&1 > $testdir/gpgv.out ; then
	echo Make should fail when gpgv not installed >&2
	exit 1
else
	if ! grep gpgv $testdir/gpgv.out 2>&1 > /dev/null; then
		echo Make shoud output gpgv in error message >&2
		exit 1
	fi
fi

mv /usr/bin/gpgv.disabled /usr/bin/gpgv

if make 2>&1 > $testdir/acl.out ; then
	echo Make should fail when acl not installed >&2
	exit 1
else
	if ! grep acl $testdir/acl.out 2>&1 > /dev/null; then
		echo Make shoud output acl in error message >&2
		exit 1
	fi
fi

apt install -y acl

if make 2>&1 > $testdir/ssh.out ; then
	echo Make should fail when /etc/ssh/sshd_config.d not exist >&2
	exit 1
else
	if ! grep sshd_config\.d $testdir/ssh.out 2>&1 > /dev/null; then
		echo Make shoud output sshd_config.d in error message >&2
		exit 1
	fi
fi

apt install -y openssh-server

if ! make ; then
	echo Make should run >&2
	exit 1
fi


echo Testsuite ran succesfully 
exit 0
