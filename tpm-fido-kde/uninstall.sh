#!/bin/bash

uninstall_tpmfido() {
	set -x
	
	rm /etc/udev/rules.d/99-tpm-custom.rules /etc/udev/rules.d/99-uhid.rules
	rm /etc/modules-load.d/uhid.conf 
	rm /usr/local/bin/tpm-fido
	rm /usr/local/libexec/tpm-fido/tpm-fido
	rmdir /usr/local/libexec/tpm-fido
	gpasswd --delete $SUDO_USER tpmfido
	groupdel tpmfido
	groupdel _tpmfido
	
	set +x
}

if [ "$1" = "uninstall_tpmfido" ]; then
	uninstall_tpmfido
	exit 0
fi

uninstall_tpmfido_gui() {
	set -x
	rm /usr/local/bin/tpmfido-gui
	rm /usr/local/bin/tpmfido-gui.sh
	set +x
}

if [ "$1" = "uninstall_tpmfido_gui" ]; then
	uninstall_tpmfido_gui
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

# shoud run as user that wants to use tpm-fido

if [ $(id -u) -eq 0 ]; then
	2>&1 echo This script should not be run as root, but as user that wants to remove tpm-fido
	exit 1
fi

ask_consent 'Remove tpmfido-gui?'

sudo ./uninstall.sh uninstall_tpmfido_gui

ask_consent 'Remove tpm-fido binary?'

sudo ./uninstall.sh uninstall_tpmfido

echo
echo Done.
echo
