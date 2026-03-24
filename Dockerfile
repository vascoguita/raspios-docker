FROM --platform=$BUILDPLATFORM debian:stable-slim@sha256:99fc6d2a0882fcbcdc452948d2d54eab91faafc7db037df82425edcdcf950e1f AS extractor

ARG RASPIOS_URL
ARG RASPIOS_SHA256

ADD --checksum=sha256:${RASPIOS_SHA256} ${RASPIOS_URL} raspios.img.xz

ENV DEBIAN_FRONTEND=noninteractive
ENV LIBGUESTFS_BACKEND=direct

RUN apt-get update && apt-get install -y --no-install-recommends \
    libguestfs-tools \
    xz-utils \
    "linux-image-$(dpkg --print-architecture)"

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
