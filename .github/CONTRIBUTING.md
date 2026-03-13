# Contributing

This repository is a community-maintained fork of the archived `linuxserver/docker-feed2toot` container. It is not an official LinuxServer.io project, though it keeps the original git history and still uses the maintained `ghcr.io/linuxserver/baseimage-alpine` base image.

## Before opening a pull request

- Keep `Dockerfile` and `Dockerfile.aarch64` aligned when a change applies to both architectures.
- Update `README.md` when runtime behavior, setup steps, or configuration paths change.
- If you change startup scripts under `root/`, test container startup and first-run config creation.
- If you change the base image, apk package set, or Python package set, regenerate `package_versions.txt` from a real build before merging. Do not hand-edit it.

## Local testing

```bash
docker buildx build --platform linux/amd64 -f Dockerfile -t docker-feed2toot:test-amd64 --load .
docker buildx build --platform linux/arm64 -f Dockerfile.aarch64 -t docker-feed2toot:test-arm64 .
```

If you change registration or cron behavior, also run the container against a throwaway `/config` directory and verify:

- `/config/feed2toot.ini` is created on first boot
- `/config/creds/` is created
- `/lsiopy/bin/register_feed2toot_app` launches the OAuth registration helper correctly

## Scope

Keep changes focused on the container and its integration points. Application-level bugs or features in `feed2toot-oauth` should usually be handled upstream at <https://github.com/theelous3/feed2toot-oauth>.
