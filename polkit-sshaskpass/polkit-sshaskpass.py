#!/usr/bin/env python3
import os
import sys

import bast1aan_polkit

ssh_askpass_prompt = os.environ.get("SSH_ASKPASS_PROMPT", default="")
SSH_ASKPASS_POLKIT = os.environ.get("SSH_ASKPASS_POLKIT", "ssh-askpass")  # program to execute beyond this one


if __name__ == "__main__":
    if ssh_askpass_prompt == "confirm":
        authorized = bast1aan_polkit.authorize(sys.argv[1])
        sys.exit(0 if authorized else 1)
    else:
        # fallback to original askpass
        os.execvp(SSH_ASKPASS_POLKIT, [SSH_ASKPASS_POLKIT, *sys.argv[1:]])
