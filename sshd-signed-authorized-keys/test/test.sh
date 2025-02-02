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
# test authorized_keys used by sshd will not change if we tamper with the file

cat /root/.ssh/id_ed25519-2.pub >> /home/user/.ssh/authorized_keys

# we can still login with default identity
ssh -o "PasswordAuthentication no" -q user@localhost exit

# we can't login with the newly added identify 
if ssh -i /root/.ssh/id_ed25519-2 -o "PasswordAuthentication no" -q user@localhost exit ; then
	echo We should not be able to login with id_ed25519-2
	exit 1
fi

# signed file should not have been touched
test "$(md5sum < /root/user/.ssh/authorized_keys)" = "$(md5sum < /var/local/sshd_signed_authorized_keys/user)"

#################################################
# test authorized_keys used by sshd does change if we add new signature

cp /root/user/.ssh/authorized_keys-2.sig /home/user/.ssh/authorized_keys.sig
chown user:user /home/user/.ssh/authorized_keys.sig

# we can still login with default identity
ssh -o "PasswordAuthentication no" -q user@localhost exit

# we now *also* can login with the newly added identify 
ssh -i /root/.ssh/id_ed25519-2 -o "PasswordAuthentication no" -q user@localhost exit

# should not contain any file
su user -c 'test "$(md5sum < /home/user/.ssh/authorized_keys)" = "$(md5sum < /var/local/sshd_signed_authorized_keys/user)"'

#################################################
# test signed authorized_keys is not updated if sig file has not changed

sleep 2

mtime_sigfile=$(stat --format %Y /var/local/sshd_signed_authorized_keys/user)

# we can still login with default identity
ssh -o "PasswordAuthentication no" -q user@localhost exit

# we now *also* can login with the newly added identify 
ssh -i /root/.ssh/id_ed25519-2 -o "PasswordAuthentication no" -q user@localhost exit

# file should not have updated
test "$mtime_sigfile" = "$(stat --format %Y /var/local/sshd_signed_authorized_keys/user)"

#################################################
# test signed authorized_keys is newer if sig file has not changed

cp /root/user/.ssh/authorized_keys /home/user/.ssh/
cp /root/user/.ssh/authorized_keys.sig /home/user/.ssh/
chown user:user /home/user/.ssh/authorized_keys.*

# we can still login with default identity
ssh -o "PasswordAuthentication no" -q user@localhost exit

# we now can no longer login with the second identify 
if ssh -i /root/.ssh/id_ed25519-2 -o "PasswordAuthentication no" -q user@localhost exit ; then
	echo We should not be able to login with id_ed25519-2
	exit 1
fi

# file should have updated
test "$(stat --format %Y /var/local/sshd_signed_authorized_keys/user)" -gt "$mtime_sigfile" 

#################################################



echo
echo '##################################'
echo Testsuite ran succesfully !
exit 0
