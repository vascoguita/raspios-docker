FROM --platform=$BUILDPLATFORM debian:stable-slim@sha256:a717a33469731894e77e912ea7d714e27c2dc38ee6554fd1a3102e92999cfc66 AS extractor

ARG RASPIOS_URL
ARG RASPIOS_SHA256

ADD --checksum=sha256:${RASPIOS_SHA256} ${RASPIOS_URL} raspios.download

ENV DEBIAN_FRONTEND=noninteractive
ENV LIBGUESTFS_BACKEND=direct

RUN apt-get update && apt-get install -y --no-install-recommends \
    libguestfs-tools \
    unzip \
    xz-utils \
    "linux-image-$(dpkg --print-architecture)"

RUN case "${RASPIOS_URL}" in \
      *.zip)    unzip -p raspios.download > raspios.img ;; \
      *.img.xz) unxz -c raspios.download > raspios.img ;; \
    esac && \
    guestfish --ro -a raspios.img -m /dev/sda2 \
    -- set-autosync false : copy-out / /mnt/

FROM scratch

COPY --from=extractor \
    --exclude=dev \
    --exclude=proc \
    --exclude=sys \
    --exclude=run \
    --exclude=var/run \
    --exclude=boot \
    --exclude=usr/share/doc \
    --exclude=usr/share/man \
    --exclude=var/lib/apt/lists \
    --exclude=var/cache/apt \
    /mnt/ /

CMD ["/bin/bash"]
