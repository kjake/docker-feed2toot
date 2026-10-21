# docker-feed2toot

Independent community-maintained fork of the archived `linuxserver/docker-feed2toot` container.

This fork keeps the original container behavior:

- cron-driven `feed2toot` execution
- persistent `/config` volume
- `PUID`, `PGID` and `TZ` environment settings

The runtime is built on the Chainguard [`cgr.dev/chainguard/wolfi-base`](https://images.chainguard.dev/directory/image/wolfi-base/overview) image. `supercronic` schedules the feed run and `su-exec` drops privileges to the configured `PUID`/`PGID`.

The packaged application has been switched from the abandoned `feed2toot` release to [`feed2toot-oauth`](https://github.com/theelous3/feed2toot-oauth), which supports the current OAuth-based registration flow for Mastodon-compatible servers.

## Attribution

- The original container repo was created and maintained by LinuxServer.io.
- This fork is maintained independently and is not an official LinuxServer.io image.

## What changed

- The image now installs `feed2toot-oauth` from PyPI.
- The base image moved from LinuxServer's Alpine image to Chainguard's Wolfi base. Wolfi packages are installed unpinned so every rebuild picks up the latest fixes; only Python is held to its major version through the `python-3` package.
- The s6-overlay init system is replaced by a small entrypoint script. The LinuxServer deprecation banner is gone.
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
- A scheduled GitHub Action rebuilds the image weekly without the layer cache, so the published image tracks the latest Wolfi base and package updates.
