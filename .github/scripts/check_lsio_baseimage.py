#!/usr/bin/env python3

import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
REGISTRY_BASE = "https://ghcr.io"
REPOSITORY = "linuxserver/baseimage-alpine"
TAG_ACCEPT = ", ".join(
    [
        "application/vnd.oci.image.index.v1+json",
        "application/vnd.docker.distribution.manifest.list.v2+json",
    ]
)


def read_current_version() -> str:
    dockerfile = (REPO_ROOT / "Dockerfile").read_text()
    dockerfile_arm = (REPO_ROOT / "Dockerfile.aarch64").read_text()

    amd64_match = re.search(
        r"^FROM\s+ghcr\.io/linuxserver/baseimage-alpine:(\d+\.\d+)$",
        dockerfile,
        re.MULTILINE,
    )
    arm64_match = re.search(
        r"^FROM\s+ghcr\.io/linuxserver/baseimage-alpine:arm64v8-(\d+\.\d+)$",
        dockerfile_arm,
        re.MULTILINE,
    )

    if not amd64_match or not arm64_match:
        raise RuntimeError("Could not parse pinned LSIO base-image versions from Dockerfiles.")

    amd64_version = amd64_match.group(1)
    arm64_version = arm64_match.group(1)
    if amd64_version != arm64_version:
        raise RuntimeError(
            f"Mismatched LSIO base-image versions: amd64={amd64_version}, arm64={arm64_version}"
        )

    return amd64_version


def fetch_registry_token() -> str:
    with urllib.request.urlopen(
        f"{REGISTRY_BASE}/token?scope=repository:{REPOSITORY}:pull",
        timeout=20,
    ) as response:
        return json.load(response)["token"]


def manifest_exists(token: str, tag: str) -> bool:
    request = urllib.request.Request(
        f"{REGISTRY_BASE}/v2/{REPOSITORY}/manifests/{tag}",
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": TAG_ACCEPT,
        },
        method="HEAD",
    )
    try:
        with urllib.request.urlopen(request, timeout=20):
            return True
    except urllib.error.HTTPError as exc:
        if exc.code == 404:
            return False
        raise


def next_versions(current: str, lookahead: int = 6) -> list[str]:
    major, minor = map(int, current.split("."))
    return [f"{major}.{minor + offset}" for offset in range(1, lookahead + 1)]


def write_outputs(values: dict[str, str]) -> None:
    output_path = os.environ.get("GITHUB_OUTPUT")
    if not output_path:
        return

    with open(output_path, "a", encoding="utf-8") as output_file:
        for key, value in values.items():
            output_file.write(f"{key}={value}\n")


def main() -> int:
    current_version = read_current_version()
    token = fetch_registry_token()

    latest_version = current_version
    for candidate in next_versions(current_version):
        amd64_exists = manifest_exists(token, candidate)
        arm64_exists = manifest_exists(token, f"arm64v8-{candidate}")
        if amd64_exists and arm64_exists:
            latest_version = candidate

    update_available = latest_version != current_version
    summary = {
        "current_version": current_version,
        "latest_version": latest_version,
        "update_available": str(update_available).lower(),
    }
    write_outputs(summary)

    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        raise SystemExit(1)
