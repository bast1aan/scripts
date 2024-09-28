#!/usr/bin/env python3
import os
import subprocess
import sys
from typing import NamedTuple

import dbus

PINENTRY = os.environ.get("PINENTRY", default="pinentry")  # program to execute beyond this one


def authorize(message: str) -> bool:

    class PolkitAuthorizationResult(NamedTuple):
        is_authorized: dbus.Boolean
        is_challenge: dbus.Boolean
        details: dbus.Dictionary

    bus = dbus.SystemBus()

    proxy = bus.get_object('org.freedesktop.PolicyKit1', '/org/freedesktop/PolicyKit1/Authority')
    authority = dbus.Interface(proxy, dbus_interface='org.freedesktop.PolicyKit1.Authority')
    system_bus_name = bus.get_unique_name()

    subject = ('system-bus-name', {'name': system_bus_name})
    action_id = 'net.welmers.bast1aan.polkit-sshaskpass'
    details = {'message': message}
    flags = 1  # AllowUserInteraction flag
    cancellation_id = ''  # No cancellation id

    result = PolkitAuthorizationResult(
        *authority.CheckAuthorization(subject, action_id, details, flags, cancellation_id)
    )
    return bool(result.is_authorized)

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
        while line := sys.stdin.readline():
            if line.startswith('SETDESC'):
                # we record the description
                message = line[8:-1]

            if line == 'CONFIRM\n':
                authorized = authorize(message)
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
                proc.stdin.write(line)
                proc_line = proc.stdout.readline()
                if not proc_line:
                    # EOF reached
                    break
                sys.stdout.write(proc_line)
