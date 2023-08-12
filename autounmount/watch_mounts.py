#!/usr/bin/env python3
"""

Watch mounts for being added, execute program if that happens.

Usage:

./watch_mounts.py /mnt/mount1 /mnt/mount2 ... /usr/local/sbin/program

Author: Bastiaan Welmers

"""
from __future__ import annotations
from types import FrameType
from typing import Iterator
import os
import sys
import subprocess
import select
import signal


def yield_added_mounts() -> Iterator[bytes]:
    fh = open('/proc/self/mounts', 'rb')
    old_content = fh.readlines()
    fh.seek(0)

    try:
        while select.select((), (), (fh.fileno(),)):
            new_content = fh.readlines()
            for line in new_content:
                if line not in old_content:
                    yield line
            fh.seek(0)
            old_content = new_content
    finally:
        print('Closing watcher on mounts.', file=sys.stderr)
        fh.close()


def main() -> None:
    argvb = tuple(map(os.fsencode, sys.argv))  # gnu/linux argv are bytes of unknown encoding
    mounts = argvb[1:-1]
    program = argvb[-1]
    for added_mount in yield_added_mounts():
        if any(mount in added_mount for mount in mounts):
            subprocess.run(program.split(b' '))


def run_with_handlers(func=main):
    """ Handle SigINT and SigTERM in more useful way than default cpython does """
    
    class SigTERM(BaseException): pass
    
    def sigterm_handler(signum: signal.Signals, frame: FrameType | None) -> None:
        """ Raise exception so the finally blocks can clean up """
        raise SigTERM(signum, frame)

    orig_sigterm_handler = signal.signal(signal.SIGTERM, sigterm_handler)

    try:
        func()
    except KeyboardInterrupt:
        # SigINT. Disable useless stacktrace, and reraise for correct exit code
        sys.excepthook = lambda exc_type, exc, traceback: None
        raise
    except SigTERM:
        # finally cleanup code has run, restore and raise original handler for correct exit code
        signal.signal(signal.SIGTERM, orig_sigterm_handler)
        signal.raise_signal(signal.SIGTERM)


if __name__ == '__main__':
    run_with_handlers()
