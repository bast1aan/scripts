#!/usr/bin/env python3

import subprocess
import sys

if __name__ == '__main__':
	new_args = []
	pinentrykwallet = False

	args = sys.argv[1:]
	args_enumerator = enumerate(args)
	for i, arg in args_enumerator:
		try:
			if arg == '-f' and args[i+1] == 'pinentry-kwallet':
				pinentrykwallet = True
				next(args_enumerator)
				continue
		except IndexError:
			pass
		new_args.append(arg)

	if pinentrykwallet:
		executable = '/usr/local/libexec/kwalletcli-pinentry.py'
	else:
		executable = '/usr/bin/kwalletcli'

	result = subprocess.run([executable, *new_args])
	exit(result.returncode)
