FROM debian:bookworm

RUN apt update && \
	apt -y install wget

RUN wget -O /etc/apt/sources.list.d/gitlab-ci-local.sources https://gitlab-ci-local-ppa.firecow.dk/gitlab-ci-local.sources && \
	apt update && \
	apt -y install gitlab-ci-local

RUN apt -y install git rsync

RUN apt -y install telnet ca-certificates curl

RUN install -m 0755 -d /etc/apt/keyrings && \
	curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
	chmod a+r /etc/apt/keyrings/docker.asc && \
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \ 
		> /etc/apt/sources.list.d/docker.list && \
	apt update

RUN apt -y install docker-ce-cli

RUN apt -y install iputils-ping vim-tiny

