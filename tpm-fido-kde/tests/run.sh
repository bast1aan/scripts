#/bin/sh

docker run -it --name tpm-fido-kde --hostname tpm-fido-kde --tmpfs /tmp --tmpfs /run -v tpm-fido-kde-apt-archives:/var/cache/apt/archives -v $(realpath ..):/tpm-fido-kde -w /tpm-fido-kde --rm tpm-fido-kde /bin/bash
