#!/bin/bash -e

install_tpmfido() {
	set -x
	groupadd -r _tpmfido || true
	groupadd -r tpmfido || true

	usermod -a -G tpmfido $SUDO_USER || true

	install -d /usr/local/libexec
	install -g tpmfido -m 750 -d /usr/local/libexec/tpm-fido
	install -g _tpmfido -m 2755 /tmp/tpm-fido/tpm-fido /usr/local/libexec/tpm-fido

	ln -snf ../libexec/tpm-fido/tpm-fido /usr/local/bin/tpm-fido
	
	install -d /etc/modules-load.d
	install -d /etc/udev/rules.d

	install -m 644 -b uhid.conf /etc/modules-load.d
	install -m 644 -b 99-tpm-custom.rules 99-uhid.rules /etc/udev/rules.d
	
	/bin/setfacl -m g:_tpmfido:rw /dev/uhid
	/bin/setfacl -m g:_tpmfido:rw /dev/tpmrm0
	set +x
}

if [ "$1" = "install_tpmfido" ]; then
	install_tpmfido
	exit 0
fi

install_tpmfido_gui() {
	set -x
	install tpmfido-gui.sh /usr/local/bin
	ln -snf tpmfido-gui.sh /usr/local/bin/tpmfido-gui
	set +x
}

if [ "$1" = "install_tpmfido_gui" ]; then
	install_tpmfido_gui
	exit 0
fi

ask() {
	echo
	echo -n "$1 (Y/n) "
	read yesno
	if [ "x$yesno" != 'xy' ] && [ "x$yesno" != 'xY' ] && [ "x$yesno" != 'x' ]; then
		return 1
	fi

}

ask_consent() {
	if ! ask "$1"; then
		2>&1 echo Aborting
		exit 1
	fi
}

test_device() {
	if [ ! -c $1 ]; then
		if [ ! -e $1 ]; then
			2>&1 echo $1 does not exist. This is required for tpm-fido to work.
			exit 1
		else
			echo $1 is a regular file, assuming testing.
		fi
	fi
}

# shoud run as user that wants to use tpm-fido

if [ $(id -u) -eq 0 ]; then
	2>&1 echo This script should not be run as root, but as user that wants to use tpm-fido
	exit 1
fi

# test availability of required device

test_device /dev/tpmrm0

test_device /dev/uhid

if groups | grep -q tss ; then
	if ask 'You are member of group tss. This is considered unsafe, because then all your user processes can 
perform private key sign actions without your consent or knowledge. Remove you from tss group?'; then
		sudo gpasswd --delete $(whoami) tss
	else
		echo Skip removing your user from group tss.
	fi
fi

ask_consent 'Install requirements go-lang, pinentry-qt and git with apt?'

sudo apt install acl pinentry-qt golang-go git 

ask_consent 'Build https://github.com/psanford/tpm-fido?'

old_pwd=$(pwd)
cd /tmp
if [ ! -d /tmp/tpm-fido ]; then
	git clone https://github.com/psanford/tpm-fido.git
fi
cd tpm-fido
go build
cd $old_pwd

ask_consent 'Install tpm-fido binary?'

sudo ./install.sh install_tpmfido

ask_consent 'Install tpmfido-gui?'

sudo ./install.sh install_tpmfido_gui

echo
echo Optionally, you can configure what version is handling /usr/bin/pinentry, or just press enter for the default.

sudo update-alternatives --config pinentry

echo
echo All done! You should relogin or restart your PC to be able to use the tpm-fido.
echo Run the program \`tpmfido-gui\' to start using webauthn.
echo Tip: use https://demo.yubico.com/webauthn-technical/ or https://webauthn.io/ to test your installation.
echo
