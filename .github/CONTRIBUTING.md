# Contributing

This repository is a community-maintained fork of the archived `linuxserver/docker-feed2toot` container. It is not an official LinuxServer.io project, though it keeps the original git history. The image is built on the Chainguard `cgr.dev/chainguard/wolfi-base` image.

## Before opening a pull request

- A single multi-arch `Dockerfile` serves both `linux/amd64` and `linux/arm64`.
- Do not pin Wolfi packages to exact versions. Unpinned packages let each rebuild pick up security fixes; holding a package to its major version, such as `python-3`, is acceptable when needed.
- Update `README.md` when runtime behavior, setup steps, or configuration paths change.
- If you change startup scripts under `root/`, test container startup and first-run config creation.
- Container security scanning and SBOM submission run in GitHub Actions after published-image builds. Use those results for dependency and vulnerability visibility instead of maintaining package inventories by hand.

## Local testing

```bash
docker buildx build --platform linux/amd64 -t docker-feed2toot:test-amd64 --load .
docker buildx build --platform linux/arm64 -t docker-feed2toot:test-arm64 .
```

If you change registration or cron behavior, also run the container against a throwaway `/config` directory and verify:

- `/config/feed2toot.ini` is created on first boot
- `/config/creds/` is created
- `/lsiopy/bin/register_feed2toot_app` launches the OAuth registration helper correctly

## Scope

Keep changes focused on the container and its integration points. Application-level bugs or features in `feed2toot-oauth` should usually be handled upstream at <https://github.com/theelous3/feed2toot-oauth>.
