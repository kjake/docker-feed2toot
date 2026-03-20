# Security Policy

## Supported Versions

This repository is maintained on a rolling basis. Security fixes are currently provided for:

| Version | Supported |
| --- | --- |
| `main` branch | Yes |
| `kjake/feed2toot:latest` | Yes |
| Older commits, historical images, and downstream forks | No |

## Scope

This policy covers vulnerabilities in this repository and the published container image, including:

- `Dockerfile` and `Dockerfile.aarch64`
- startup scripts and runtime logic under `root/`
- default configuration shipped with the image
- GitHub Actions and release automation in this repository

This repo packages [`feed2toot-oauth`](https://github.com/theelous3/feed2toot-oauth). If a vulnerability is in the upstream application itself rather than this container packaging, please report it upstream as well.

## Reporting a Vulnerability

Please do not post exploit details, tokens, or credential files in a public issue. In particular, never share files from `/config/creds/` publicly.

If GitHub shows a private vulnerability reporting option for this repository, use that first. If it does not, open a minimal public issue requesting a private follow-up path and do not include sensitive details.

Please include:

- the affected image tag or commit SHA
- the target architecture (`amd64` or `arm64`)
- clear reproduction steps
- impact assessment and any suggested mitigation
- whether the issue appears to be in this container repo or in `feed2toot-oauth`

## What to Expect

- An initial acknowledgement target of 5 business days
- A best-effort reproduction and triage by the maintainer
- Coordination on a fix and disclosure timing when the issue is confirmed

Support is best-effort for this community-maintained fork, but credible reports will be taken seriously and handled as quickly as possible.
