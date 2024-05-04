#!/bin/sh

tpm-fido >> $XDG_RUNTIME_DIR/tpm-fido.log 2>&1 &
pid=$!
	
echo 'SETTITLE tpm-fido
SETDESC tpm-fido is running.
SETOK Close
MESSAGE
' | pinentry-qt

kill $pid
