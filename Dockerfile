FROM --platform=$BUILDPLATFORM debian:stable-20260223-slim AS extractor

ARG RASPIOS_URL

ADD ${RASPIOS_URL} raspios.img.xz

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
    /mnt/ /

CMD ["/bin/bash"]
