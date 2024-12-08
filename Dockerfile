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
    && apt-get install -y ca-certificates \
        fonts-freefont-ttf \
        fonts-kacst \
        fonts-thai-tlwg \
        fonts-wqy-zenhei \
        libasound2 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libatspi2.0-0 \
        libc6 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libdrm2 \
        libexpat1 \
        libgbm1 \
        libgconf-2-4 \
        libgdk-pixbuf2.0-0 \
        libglib2.0-0 \
        libgtk-3-0 \
        libfontconfig1 \
        libnspr4 \
        libnss3 \
        libpango-1.0-0 \
        libstdc++6 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxkbcommon0 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        procps \
        tzdata \
        xvfb \
        --no-install-recommends \
    && apt-get clean -y \
    && mkdir -p /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix

# Add non-root user
RUN useradd -ms /bin/bash playwright
# Run as non-privileged
USER playwright
WORKDIR /home/playwright

COPY --from=builder /go/bin/playwright /home/playwright
RUN /home/playwright/playwright install chromium && rm /home/playwright/playwright
