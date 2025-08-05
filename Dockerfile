FROM alpine:3.22.1 AS base

ARG ROOTFS_URL
ADD ${ROOTFS_URL} root.tar.xz
RUN unxz -c root.tar.xz | tar -x -C /mnt \
    --exclude=./dev \
    --exclude=./proc \
    --exclude=./sys \
    --exclude=./run \
    --exclude=./var/run

FROM scratch

COPY --from=base /mnt/ /

CMD ["bin/bash"]
