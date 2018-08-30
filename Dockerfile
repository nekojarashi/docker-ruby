FROM ruby:2.3.7-stretch
LABEL maintainer="y-okubo"

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
&&  apt-get update \
&&  apt-get install -y --no-install-recommends \
    curl \
    libcurl4-openssl-dev \
    dtach \
    ffmpeg \
    fontconfig \
    libfreetype6-dev \
    git \
    hash-slinger \
    imagemagick \
    libmagick++-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    libexif12 \
    libexif-dev \
    libjpeg-dev \
    libsndfile1 \
    libsndfile-dev \
    libstdc++ \
    libxslt-dev \
    locales \
    mysql-client \
    default-libmysqlclient-dev \
    nodejs \
    ssh \
    libimage-exiftool-perl \
    libreadline-dev \
    libsqlite-dev \
    sudo \
    tzdata \
    wget \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/* \
&&  locale-gen ja_JP.UTF-8 \
&&  mkdir /root/.ssh \
&&  echo 'host *' >> /root/.ssh/config \
&&  echo '  StrictHostKeyChecking no' >> /root/.ssh/config \
&&  echo '  UserKnownHostsFile=/dev/null' >> /root/.ssh/config

ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:en
ENV LC_ALL ja_JP.UTF-8

EXPOSE 3000