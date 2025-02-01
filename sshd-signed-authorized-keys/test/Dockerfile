FROM debian:bookworm

RUN apt update && apt install -y make acl gpgv openssh-server

COPY test.sh /root/
COPY subject /root/subject
