# syntax=docker/dockerfile:1

FROM cgr.dev/chainguard/wolfi-base:latest

# set version label
ARG BUILD_DATE
ARG VERSION
ARG FEED2TOOT_VERSION
LABEL build_version="docker-feed2toot version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="community"

# environment settings
ENV PYTHONIOENCODING=utf-8 \
    PYTHONUNBUFFERED=1 \
    TZ=Etc/UTC

# packages track the latest Wolfi builds; only python is held to its major version
RUN \
  echo "**** install packages ****" && \
  apk add -U --no-cache \
    python-3 \
    su-exec \
    supercronic \
    tzdata && \
  echo "**** install feed2toot-oauth ****" && \
  python3 -m venv /lsiopy && \
  /lsiopy/bin/pip install --no-cache-dir \
    "feed2toot-oauth${FEED2TOOT_VERSION:+==${FEED2TOOT_VERSION}}" && \
  echo "**** remove pip from the runtime venv ****" && \
  /lsiopy/bin/pip uninstall -y pip && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /root/.cache

# add local files
COPY root/ /

# ports and volumes
VOLUME /config

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["supercronic", "-passthrough-logs", "/etc/crontabs/abc"]
