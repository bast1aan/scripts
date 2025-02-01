FROM debian:bookworm

RUN apt update && apt install -y make acl gpgv openssh-server

COPY test.sh /root/
COPY subject /root/subject
COPY user /root/user

COPY id_ed25519* /root/.ssh/

COPY test@example.com.gpg /root/

RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/id_ed25519

RUN useradd -m user
