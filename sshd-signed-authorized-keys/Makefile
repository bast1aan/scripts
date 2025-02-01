.PHONY: install test-requirements

install: test-requirements
	install -d -m 0755 -o root /var/local/sshd_signed_authorized_keys
	install -d -m 0755 -o root /usr/local/libexec
	install -m 755 sshd_authorized_keys.sh /usr/local/libexec/sshd_authorized_keys
	install -m 644 authorized_keys.conf /etc/ssh/sshd_config.d/

test-requirements:
	test -x /usr/bin/gpgv || (echo gpgv not found, install 'gpgv' package? >&2 ; false)
	test -x /bin/setfacl || (echo setfacl not found, install 'acl' package? >&2 ; false)
	test -d /etc/ssh/sshd_config.d || (echo /etc/ssh/sshd_config.d directory not found >&2; false)
	
