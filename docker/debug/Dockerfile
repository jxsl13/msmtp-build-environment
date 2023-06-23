# Use old linux in order to support old variants (especially due to glibc/libc.so shared libraries)
FROM debian:wheezy


USER root
ENV LANG C.UTF-8

# skips interactive interaction where you need to enter your timezone.
# https://askubuntu.com/questions/909277/avoiding-user-interaction-with-tzdata-when-installing-certbot-in-a-docker-contai/1098881#1098881
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo "\
deb http://archive.debian.org/debian/ wheezy main non-free contrib \n\
deb-src http://archive.debian.org/debian/ wheezy main non-free contrib \n\
\n\
deb http://archive.debian.org/debian/ wheezy-backports main non-free contrib \n\
deb-src http://archive.debian.org/debian/ wheezy-backports main non-free contrib \n\
\n\
deb http://archive.debian.org/debian-security/ wheezy/updates main non-free contrib \n\
deb-src http://archive.debian.org/debian-security/ wheezy/updates main non-free contrib \n\
"> /etc/apt/sources.list

RUN echo '\
#!/bin/sh \n\
readlink -f -- "$@" \n\
'> /bin/realpath && chmod +x /bin/realpath


# reference: https://pythonspeed.com/articles/security-updates-in-docker/
# update, upgrade, install, cleanup
RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get upgrade -y &&\
    apt-get install -y --force-yes\
    nano vim \
    man-db\
    gawk \
    apt-utils autoconf autogen pkg-config\
    aufs-tools tree libtool \
    make automake cmake patch\
    git curl tar unzip\
    build-essential gcc g++ clang\
    perl libperl-dev \
    bison \
    texinfo \
    gettext
    #&& rm -rf /var/lib/apt/lists/*\
    #&& apt-get clean
    #openjdk-8-jdk \


RUN mkdir -p /build
WORKDIR /build

ENV PREFIX=/usr/local

VOLUME [ "/build" ]
