FROM --platform=$BUILDPLATFORM debian:stable-slim@sha256:e51bfcd2226c480a5416730e0fa2c40df28b0da5ff562fc465202feeef2f1116 AS extractor

ARG DATE
ARG SUITE
ARG ARCH

ENV DEBIAN_FRONTEND=noninteractive
ENV LIBGUESTFS_BACKEND=direct

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libguestfs-tools \
    xz-utils \
    "linux-image-$(dpkg --print-architecture)"

RUN URL="https://downloads.raspberrypi.com/raspios_lite_${ARCH}/images/raspios_lite_${ARCH}-${DATE}/${DATE}-raspios-${SUITE}-${ARCH}-lite.img.xz" && \
    curl -fsSL "${URL}" -o raspios.img.xz && \
    curl -fsSL "${URL}.sha256" | awk '{print $1 "  raspios.img.xz"}' | sha256sum -c

RUN unxz raspios.img.xz && \
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
