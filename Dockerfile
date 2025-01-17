# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.17

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PIWIGO_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    exiftool \
    ffmpeg \
    imagemagick \
    libjpeg-turbo-utils \
    mediainfo \
    php81-apcu \
    php81-cgi \
    php81-ctype \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-gd \
    php81-ldap \
    php81-mysqli \
    php81-mysqlnd \
    php81-pear \
    php81-pecl-imagick \
    php81-xsl \
    php81-zip \
    poppler-utils \
    re2c && \
  apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    php81-pecl-xmlrpc && \
  echo "**** download piwigo ****" && \
  if [ -z ${PIWIGO_RELEASE+x} ]; then \
    PIWIGO_RELEASE=$(curl -sX GET "https://api.github.com/repos/Piwigo/Piwigo/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  mkdir -p /app/www/public && \
  curl -o \
    /tmp/piwigo.zip -L \
    "https://piwigo.org/download/dlcounter.php?code=${PIWIGO_RELEASE}" && \
  unzip -q /tmp/piwigo.zip -d /tmp && \
  mv /tmp/piwigo/* /app/www/public && \
  # The max filesize is 2M by default, which is way to small for most photos
  sed -ri 's/^upload_max_filesize = .*/upload_max_filesize = 100M/' /etc/php81/php.ini && \
  # The max post size is 8M by default, it must be at least max_filesize
  sed -ri 's/^post_max_size = .*/post_max_size = 100M/' /etc/php81/php.ini && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config /gallery
