## Summary

Describe the change clearly and concisely.

## Why

Explain the problem being solved or the reason for the change.

## Testing

- [ ] `docker buildx build --platform linux/amd64 -f Dockerfile -t docker-feed2toot:test-amd64 --load .`
- [ ] `docker buildx build --platform linux/arm64 -f Dockerfile.aarch64 -t docker-feed2toot:test-arm64 .`
- [ ] Runtime behavior checked if startup/config logic changed

## Notes

Add any migration notes, compatibility concerns, or upstream references here.
