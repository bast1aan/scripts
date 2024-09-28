#!/usr/bin/env -S python3 -u
import os
import subprocess
import sys

import bast1aan_polkit

PINENTRY = os.environ.get("PINENTRY", default="pinentry")  # program to execute beyond this one
DEBUG = False


_log = None

def debug(*msgs: str) -> None:
    global _log
    if not DEBUG: return
    if not _log: _log = open('/tmp/polkit-pinentry.log', 'a')
    _log.write(''.join(msgs))
    _log.flush()

if __name__ == "__main__":
    message = ''
    popen = subprocess.Popen(
        [PINENTRY, *sys.argv[1:]],
        bufsize=1, # 1 means, buffer per line
        stdout=subprocess.PIPE,
        stdin=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        universal_newlines=True
    )
    # mini Assuan proxy
    with popen as proc:
        greeting = proc.stdout.readline()
        sys.stdout.write(greeting)
        while line := sys.stdin.readline().rstrip():
            if line.startswith('SETDESC'):
                # we record the description
                message = line[8:]

            if line == 'CONFIRM':
                authorized = bast1aan_polkit.authorize(message)
                if authorized:
                    sys.stdout.write("OK\n")
                else:
                    sys.stdout.write("ERR 83886179 Operation cancelled\n")
                # we are done. Cancel the underlying pinentry and exit.
                proc.stdin.write("BYE\n")
                break
            else:
                # if line is not CONFIRM, then just pass every line to the
                # underlying pinentry
                debug("WRITING TO PROC: ", repr(line), '\n')
                proc.stdin.write(line + '\n')
                proc_line = proc.stdout.readline()
                if not proc_line:
                    # EOF reached
                    break
                debug("WRITING TO STDOUT: ", repr(proc_line), '\n')
                sys.stdout.write(proc_line)
