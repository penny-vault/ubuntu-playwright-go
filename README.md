# ubuntu-playwright-go

Runtime base image for Penny Vault Go services that need a real
browser (TradingView scraping, etc.). Saves every consuming Dockerfile
from re-installing Chromium and its 40-odd graphics/font dependencies.

Published as [`pennyvault/playwright-go`](https://hub.docker.com/r/pennyvault/playwright-go) on Docker Hub.

## What's inside

- Ubuntu 24.04 (`t64` packages — Ubuntu's 64-bit time_t transition)
- `playwright` CLI from `playwright-community/playwright-go`
- Chromium (installed via `playwright install`)
- Headful-friendly extras: `xvfb`, font packages, `ca-certificates`, `tzdata`
- A non-privileged `ubuntu` user (uid 1000) with `$HOME=/home/ubuntu`

Built and pushed by `.github/workflows/docker.yml` on push to `main`,
on a weekly schedule (Tuesdays 00:25 UTC), and via `workflow_dispatch`.
Multi-arch: `linux/amd64`, `linux/arm64`.

## Using it

Drop the binary into `/home/ubuntu` (or wherever) and set the
entrypoint. The container's default `WORKDIR` is `/home/ubuntu` and the
default `USER` is `ubuntu`, so you don't need to set them yourself.

Pattern from `importers/zacks-rank/Dockerfile`:

```dockerfile
FROM golang AS builder
WORKDIR /go/src
COPY ./ .
RUN make build

FROM pennyvault/playwright-go
COPY --from=builder /go/src/myservice /home/ubuntu
ENTRYPOINT ["/home/ubuntu/myservice"]
```

**Important:** the builder must be Debian/glibc-based (`golang`, not
`golang:alpine`). Binaries from a musl-libc builder won't run on this
Ubuntu base.

If your service calls `time.LoadLocation("America/New_York")` (or any
named zone), you're fine — `tzdata` is installed.

## Build args (optional)

- `BUILD_DATE` — ISO 8601 timestamp, set into `org.opencontainers.image.created`.
- `VCS_REF` — short commit SHA, set into `org.opencontainers.image.revision`.

The workflow doesn't currently set these, but they're available if a
manual build wants them.
