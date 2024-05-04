FROM ubuntu:24.04

RUN apt update
RUN apt -y install sudo

RUN apt -y install pinentry-qt git golang-go

# deinstall again, so the packages are removed but de depencencies are kept, and the actual 
# install step can be tested.
# (seems no easy command for that in apt)
RUN apt -y remove git pinentry-qt golang-go

RUN echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/01keep-deb
RUN rm /etc/apt/apt.conf.d/docker-clean

RUN groupadd user

RUN useradd -m -s /bin/bash -g user -G sudo user

RUN echo 'user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/user

USER user
