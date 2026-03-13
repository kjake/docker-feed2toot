# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.23

# set version label
ARG BUILD_DATE
ARG VERSION
ARG FEED2TOOT_VERSION
LABEL build_version="docker-feed2toot version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="community"

# environment settings
ENV PYTHONIOENCODING=utf-8 \
    PYTHONUNBUFFERED=1

RUN \
  echo "**** install packages ****" && \
  apk add  -U --update --no-cache \
    python3 && \
  echo "**** install feed2toot-oauth ****" && \
  if [ -z ${FEED2TOOT_VERSION+x} ]; then \
    FEED2TOOT_VERSION=$(curl -sL https://pypi.org/pypi/feed2toot-oauth/json | jq -r '.info.version'); \
  fi && \
  python3 -m venv /lsiopy && \
  /lsiopy/bin/pip install -U --no-cache-dir \
    pip \
    wheel && \
  /lsiopy/bin/pip install -U --no-cache-dir \
    feed2toot-oauth=="${FEED2TOOT_VERSION}" && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
COPY root/ /

# ports and volumes
VOLUME /config
