#!/usr/bin/env python3

import sys
import subprocess
import getopt

import keyring
import keyring.backends.kwallet

SERVICE_NAME = 'pinentry-kwallet'  # important this stays the same, for security

def _request_confirmation(msg: str) -> int:
	result = subprocess.run(['kwalletcli_getpin', '-b', '-t', msg])
	return result.returncode

def main(entry: str) -> int:
	if entry.startswith('pass-v'):
		# a decryption value was requested, this must be confirmed.
		res = _request_confirmation(entry[7:])
		if res != 0:
			return res

	backend = keyring.backends.kwallet.DBusKeyring()

	keyring.set_keyring(backend)

	pw = keyring.get_password(SERVICE_NAME, entry)

	if pw:
		print(pw)
		return 0
	else:
		return 1

if __name__ == '__main__':
	args = sys.argv[1:]
	entry = ''

	try:
		for i, arg in enumerate(args):
			if arg == '-e':
				entry = args[i + 1]
	except IndexError:
		pass

	if not entry:
		print('Usage: -e "entry to be requested from the pinentry-kwallet service"')
		exit(1)

	result = main(entry)
	exit(result)
