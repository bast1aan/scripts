#!/bin/sh

set -e -x

testdir=$(mktemp -d)

cd /root/subject

#####################################################

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

#####################################################

mv /bin/setfacl /bin/setfacl.disabled

if make 2>&1 > $testdir/acl.out ; then
	echo Make should fail when acl not installed >&2
	exit 1
else
	if ! grep acl $testdir/acl.out 2>&1 > /dev/null; then
		echo Make shoud output acl in error message >&2
		exit 1
	fi
fi

mv /bin/setfacl.disabled /bin/setfacl

####################################################

mv /etc/ssh/sshd_config.d /etc/ssh/sshd_config.d.disabled

if make 2>&1 > $testdir/ssh.out ; then
	echo Make should fail when /etc/ssh/sshd_config.d not exist >&2
	exit 1
else
	if ! grep sshd_config\.d $testdir/ssh.out 2>&1 > /dev/null; then
		echo Make shoud output sshd_config.d in error message >&2
		exit 1
	fi
fi

mv /etc/ssh/sshd_config.d.disabled /etc/ssh/sshd_config.d

####################################################

if ! make ; then
	echo Make should run >&2
	exit 1
fi

###################################################

test -f /usr/local/libexec/sshd_authorized_keys
test -x /usr/local/libexec/sshd_authorized_keys
test -f /etc/ssh/sshd_config.d/authorized_keys.conf
test -d /var/local/sshd_signed_authorized_keys
test -d /usr/local/etc/sshd_authorized_keys_keyring

###################################################
# arrange sshd

mkdir /home/user/.ssh
cp /root/user/.ssh/authorized_keys /home/user/.ssh/
chown -R user:user /home/user/.ssh
chmod 700 /home/user/.ssh
cp /root/test@example.com.gpg /usr/local/etc/sshd_authorized_keys_keyring/
/etc/init.d/ssh restart
ssh-keyscan localhost >> ~/.ssh/known_hosts

##################################################
# test without signature

# try if we can authenticate succesfully
ssh -o "PasswordAuthentication no" -q user@localhost exit

# should not contain any file
test -z "$(ls /var/local/sshd_signed_authorized_keys/)"

#################################################
# test with signature

cp /root/user/.ssh/authorized_keys.sig /home/user/.ssh/
chown user:user /home/user/.ssh/authorized_keys.sig


ssh -o "PasswordAuthentication no" -q user@localhost exit

# signed file should be picked up, should be readable by user with ACL
su user -c 'test "$(md5sum < /home/user/.ssh/authorized_keys)" = "$(md5sum < /var/local/sshd_signed_authorized_keys/user)"'

#################################################

echo
echo '##################################'
echo Testsuite ran succesfully !
exit 0
