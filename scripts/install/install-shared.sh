#!/bin/bash

export LANG=en_US.UTF-8
export DEBIAN_FRONTEND=noninteractive

apt_install='apt-get install -y --no-install-recommends'

# update apt and locales
apt-get update \
    && $apt_install locales locales-all \
    && echo "$LANG UTF-8" | tee /etc/locale.gen \
    && locale-gen $LANG \
    && update-locale LANG=$LANG LC_CTYPE=$LANG

# upgrade existing packages
$apt_install software-properties-common
apt-get dist-upgrade -y --no-install-recommends -o Dpkg::Options::="--force-confold"

# install basic packages needed for all EC2 instances
$apt_install build-essential \
             iputils-ping \
             curl wget \
             iptables \
             psmisc \
             libpq-dev postgresql-client \
             python3-pip \
             zip unzip \
             openssh-client \
             git \
             tzdata

# set local timezone to Berlin
# TODO set based on user input
ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata
