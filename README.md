# docker-feed2toot

Independent community-maintained fork of the archived `linuxserver/docker-feed2toot` container.

This fork keeps the original container model intact:

- cron-driven `feed2toot` execution
- persistent `/config` volume
- s6-based runtime on top of the actively maintained `ghcr.io/linuxserver/baseimage-alpine` base image

The packaged application has been switched from the abandoned `feed2toot` release to [`feed2toot-oauth`](https://github.com/theelous3/feed2toot-oauth), which supports the current OAuth-based registration flow for Mastodon-compatible servers.

## Attribution

- The original container repo was created and maintained by LinuxServer.io.
- This fork is maintained independently and is not an official LinuxServer.io image.
- The fork continues to use the LinuxServer base image because that dependency is still maintained separately.

## What changed

- The image now installs `feed2toot-oauth` from PyPI.
- New default configs expect credentials under `/config/creds/`.
- `/lsiopy/bin/register_feed2toot_app` is preserved as a compatibility wrapper and now runs the new `feed2toot-register-app` helper from `/config`.

## Published image

- This repo currently publishes `kjake/feed2toot:latest`.
- Published architectures are `linux/amd64` and `linux/arm64`.
- If you fork this repo and change `IMAGE_NAME` in `.github/workflows/docker.yml`, substitute your own image tag in the examples below.

## Usage

### docker-compose

```yaml
services:
  feed2toot:
    image: kjake/feed2toot:latest
    container_name: feed2toot
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - FEED_LIMIT=5
    volumes:
      - /path/to/feed2toot/config:/config
    restart: unless-stopped
```

If you are developing the container locally, replace the `image:` line with `build: .`.

### docker run

```bash
docker run -d \
  --name=feed2toot \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e FEED_LIMIT=5 \
  -v /path/to/feed2toot/config:/config \
  --restart unless-stopped \
  kjake/feed2toot:latest
```

## First-time setup

Generate Mastodon OAuth credentials:

```bash
docker run --rm -it \
  -v /path/to/feed2toot/config:/config \
  -e PUID=1000 \
  -e PGID=1000 \
  kjake/feed2toot:latest \
  /lsiopy/bin/register_feed2toot_app
```

That command writes credentials into:

- `/config/creds/feed2toot_clientcred.secret`
- `/config/creds/feed2toot_usercred.secret`

Then edit `/config/feed2toot.ini` to set your instance URL, feed URL, and toot template.

## Default config

Fresh config volumes are seeded with:

```ini
[mastodon]
instance_url=https://mastodon.social
user_credentials=/config/creds/feed2toot_usercred.secret
client_credentials=/config/creds/feed2toot_clientcred.secret

[cache]
cachefile=/config/cache.db

[rss]
uri=https://www.journalduhacker.net/rss
toot={title} {link}

[lock]
lock_file=/config/feed2toot.lock

[hashtaglist]
several_words_hashtags_list=/config/hashtags.txt
```

## Notes

- Existing persisted configs are not overwritten.
- If you are migrating from the original archived image, re-registering OAuth credentials is recommended.
- The upstream app documentation lives at <https://github.com/theelous3/feed2toot-oauth>.
- A scheduled GitHub Action opens or updates a maintenance issue when LinuxServer publishes a newer Alpine base-image series.
