#!/bin/sh -e

docker build -t gitlab-ci-local -f Dockerfile .

scriptdir=$(dirname $0)

if [ ! -f "$scriptdir/root/.docker/config.json" ] && [ -f "$HOME/.docker/config.json" ]; then
	echo
	read -p "$scriptdir/root/.docker/config.json does not yet exist. Do you want to copy auth definitions from $HOME/.docker/config.json? (y/n)" yesno
	if [ $yesno = 'y' ] || [ $yesno = 'Y' ]; then
		mkdir -p $scriptdir/root/.docker
		python3 $scriptdir/copy_docker_auths.py $HOME/.docker/config.json $scriptdir/root/.docker/config.json
		echo Done.
	else
		echo Skipped creating $scriptdir/root/.docker/config.json
	fi
fi
