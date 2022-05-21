FROM golang AS builder
WORKDIR /go/src
RUN go install github.com/playwright-community/playwright-go/cmd/playwright@latest
FROM ubuntu

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
RUN apt-get update && apt-get install -y ca-certificates tzdata libglib2.0-0 libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdbus-1-3 libdrm2 libxcb1 libxkbcommon0 libx11-6 libxcomposite1 libxdamage1 libxext6 libxfixes3 libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0 && apt-get clean -y

# Add non-root user
RUN useradd -ms /bin/bash playwright
# Run as non-privileged
USER playwright
WORKDIR /home/playwright

COPY --from=builder /go/bin/playwright /home/playwright
RUN /home/playwright/playwright install chromium && rm /home/playwright/playwright
