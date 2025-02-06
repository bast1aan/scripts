#!/bin/sh

# Run an executable only if a valid gpg signature exists.
# 
# Usage: vexec path/to/executable args...
#
# It will only execute the script if path/to/executable.sig exists and is a
# valid gpg signature.
# Keyrings to be examined should be in /usr/local/etc/vexec-keyring/ directory.
# 
# Executable can also be a script with a valid shebang.
#
# Tip: symlink or install this dir in /bin/ so it is very easy to type it,
# like /bin/vexec ...
#

cmd=$1
shift
keyrings='' 

for f in /usr/local/etc/vexec-keyring/*; do
	keyrings="$keyrings --keyring=$f"
done

if gpgv $keyrings $cmd.sig $cmd; then
	$cmd "$@"
fi

