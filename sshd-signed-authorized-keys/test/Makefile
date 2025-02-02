run-tests:
	mkdir subject || true
	rm subject/* || true
	cd subject && find ../../ -maxdepth 1 -type f -exec cp {} ./ \;
	docker build -t sshd-signed-authorized-keys-test -f Dockerfile .
	docker run --rm sshd-signed-authorized-keys-test /root/test.sh
