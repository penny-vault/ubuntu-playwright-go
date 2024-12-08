FROM golang AS builder
WORKDIR /go/src
RUN go install github.com/playwright-community/playwright-go/cmd/playwright@latest
FROM ubuntu:24.04

ARG BUILD_DATE
ARG VCS_REF

LABEL org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.description="Playwright-go running in a Docker container" \
    org.opencontainers.image.title="playwright-go" \
    org.opencontainers.image.documentation="https://github.com/penny-vault/ubuntu-playwright-go/blob/master/README.md" \
    org.opencontainers.image.source="https://github.com/penny-vault/ubuntu-playwright-go" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.vendor="penny-vault" \
    org.opencontainers.image.version="latest"

COPY --from=builder /go/bin/playwright /usr/bin
RUN apt-get update \
    && apt-get update&& apt-get install -y --no-install-recommends ca-certificates \
        libasound2t64 \
        libatk-bridge2.0-0t64 \
        libatk1.0-0t64 \
        libatspi2.0-0t64 \
        libcairo2 \
        libcups2t64 \
        libdbus-1-3 \
        libdrm2 \
        libgbm1 \
        libglib2.0-0t64 \
        libnspr4 \
        libnss3 \
        libpango-1.0-0 \
        libx11-6 \
        libxcb1 \
        libxcomposite1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxkbcommon0 \
        libxrandr2 \
        xvfb \
        fonts-noto-color-emoji \
        fonts-unifont \
        libfontconfig1 \
        libfreetype6 \
        xfonts-cyrillic \
        xfonts-scalable \
        fonts-liberation \
        fonts-ipafont-gothic \
        fonts-wqy-zenhei \
        fonts-tlwg-loma-otf \
        fonts-freefont-ttf \
    && apt-get clean -y \
    && mkdir -p /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix

# Run as non-privileged
USER ubuntu
WORKDIR /home/ubuntu

COPY --from=builder /go/bin/playwright /home/ubuntu
RUN /home/ubuntu/playwright install chromium && rm /home/ubuntu/playwright
