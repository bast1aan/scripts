#!/bin/sh

. ./projects.conf

project_volumes=""
help_text="Available projects from projects.conf:\n"

for project in $projects; do
	project_base=$(basename $project)
	project_volumes="$project_volumes -v $project:/srv/$project_base"
	help_text="$help_text/srv/$project_base\n"
done

echo Starting up..

docker network create gitlab-ci-local

docker run --privileged --network gitlab-ci-local --name gitlab-ci-local-dind --network-alias docker -v $XDG_RUNTIME_DIR/gitlab-ci-local-run:/run --rm -d docker:dind

sleep 5

printf "$help_text"

docker run -it --name gitlab-ci-local --network gitlab-ci-local --hostname gitlab-ci-local -e DOCKER_HOST=unix:///var/run/docker.sock -v ./root:/root $project_volumes --tmpfs /tmp --tmpfs /run -v $XDG_RUNTIME_DIR/gitlab-ci-local-run/docker.sock:/var/run/docker.sock --rm gitlab-ci-local bash

docker stop gitlab-ci-local-dind

docker network rm gitlab-ci-local
