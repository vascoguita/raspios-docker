FROM --platform=$BUILDPLATFORM debian:stable-20260223-slim AS extractor

ARG SUITE
ARG MIRROR
ARG ARCH

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    debootstrap \
    wget

RUN debootstrap --arch=${ARCH} --no-check-gpg ${SUITE} /mnt ${MIRROR}

FROM scratch

COPY --from=extractor \
    --exclude=dev \
    --exclude=proc \
    --exclude=sys \
    --exclude=run \
    --exclude=var/run \
    --exclude=boot \
    /mnt/ /

CMD ["/bin/bash"]
