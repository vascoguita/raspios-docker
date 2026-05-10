# Raspberry Pi OS Docker Image

Official root filesystems. Multi-arch. Auto-updated weekly.

[![Docker Hub](https://img.shields.io/docker/pulls/vascoguita/raspios)](https://hub.docker.com/r/vascoguita/raspios)
[![License MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/license/mit)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](.github/CODE_OF_CONDUCT.md)
[![CodeQL](https://github.com/vascoguita/raspios-docker/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/vascoguita/raspios-docker/actions/workflows/github-code-scanning/codeql)
[![Build](https://github.com/vascoguita/raspios-docker/actions/workflows/docker.yml/badge.svg)](https://github.com/vascoguita/raspios-docker/actions/workflows/docker.yml)

![Raspberry Pi OS Docker banner](https://repository-images.githubusercontent.com/989342487/1cd8280d-bb4b-48e0-99c6-ed2d65f59be3)

## Why?

Building software for the Raspberry Pi usually means either cross-compiling
with a toolchain you don't fully trust, waiting hours on the Pi itself, or
cobbling together a chroot from a raw `.img` file.

**raspios-docker** gives you the real Raspberry Pi OS userland - extracted
directly from the official Lite release images - as a standard Docker image you
can `pull` and `run` in seconds.

- **Develop and test Raspberry Pi software on any machine** - your laptop, a CI
  runner, a cloud VM.
- **Reproduce production environments** - the image _is_ Raspberry Pi OS, not a
  Debian derivative patched to look like one.
- **Pin to a specific release** - immutable date-stamped tags guarantee
  bit-for-bit reproducibility.

## Quick Start

```bash
docker run --rm -it --platform linux/arm64 vascoguita/raspios
```

That's it. You're inside a Raspberry Pi OS shell.

> [!IMPORTANT]
> Always specify `--platform` to select the target architecture. Use
> `linux/arm64` for 64-bit or `linux/arm/v7` / `linux/arm/v6` for 32-bit
> images.

Use it as a base image in your Dockerfile:

```Dockerfile
FROM vascoguita/raspios:latest

RUN apt-get update && apt-get install -y python3
COPY app/ /opt/app/
CMD ["python3", "/opt/app/main.py"]
```

> [!NOTE]
> **Running on an x86_64 host?** You'll need QEMU for ARM emulation.
> See [Emulation Setup](#emulation-setup-for-x86_64-hosts) below.

## Available Tags

All images are published to
[**Docker Hub → `vascoguita/raspios`**](https://hub.docker.com/r/vascoguita/raspios).

### Rolling tags *(always point to the latest release)*

| Tag | Architectures | Description |
|-----|---------------|-------------|
| [`latest`](https://hub.docker.com/layers/vascoguita/raspios/latest) / [`arm64`](https://hub.docker.com/layers/vascoguita/raspios/arm64) | `linux/arm64` | Latest 64-bit release |
| [`armhf`](https://hub.docker.com/layers/vascoguita/raspios/armhf) | `linux/arm/v6` · `linux/arm/v7` · `linux/arm64` | Latest 32-bit release |
| [`trixie`](https://hub.docker.com/layers/vascoguita/raspios/trixie) / [`arm64-trixie`](https://hub.docker.com/layers/vascoguita/raspios/arm64-trixie) | `linux/arm64` | Latest 64-bit Trixie release |
| [`armhf-trixie`](https://hub.docker.com/layers/vascoguita/raspios/armhf-trixie) | `linux/arm/v6` · `linux/arm/v7` · `linux/arm64` | Latest 32-bit Trixie release |
| [`bookworm`](https://hub.docker.com/layers/vascoguita/raspios/bookworm) / [`arm64-bookworm`](https://hub.docker.com/layers/vascoguita/raspios/arm64-bookworm) | `linux/arm64` | Latest 64-bit Bookworm release |
| [`armhf-bookworm`](https://hub.docker.com/layers/vascoguita/raspios/armhf-bookworm) | `linux/arm/v6` · `linux/arm/v7` · `linux/arm64` | Latest 32-bit Bookworm release |
| [`bullseye`](https://hub.docker.com/layers/vascoguita/raspios/bullseye) / [`arm64-bullseye`](https://hub.docker.com/layers/vascoguita/raspios/arm64-bullseye) | `linux/arm64` | Latest 64-bit Bullseye release |
| [`armhf-bullseye`](https://hub.docker.com/layers/vascoguita/raspios/armhf-bullseye) | `linux/arm/v6` · `linux/arm/v7` · `linux/arm64` | Latest 32-bit Bullseye release |
| [`buster`](https://hub.docker.com/layers/vascoguita/raspios/buster) / [`arm64-buster`](https://hub.docker.com/layers/vascoguita/raspios/arm64-buster) | `linux/arm64` | Latest 64-bit Buster release |
| [`armhf-buster`](https://hub.docker.com/layers/vascoguita/raspios/armhf-buster) | `linux/arm/v6` · `linux/arm/v7` · `linux/arm64` | Latest 32-bit Buster release |

### Immutable tags *(pinned, never overwritten)*

| Tag pattern | Example | Description |
|-------------|---------|-------------|
| `arm64-<suite>-YYYY-MM-DD` | [`arm64-bookworm-2025-05-06`](https://hub.docker.com/layers/vascoguita/raspios/arm64-bookworm-2025-05-06) | Specific 64-bit release |
| `armhf-<suite>-YYYY-MM-DD` | [`armhf-bookworm-2025-05-06`](https://hub.docker.com/layers/vascoguita/raspios/armhf-bookworm-2025-05-06) | Specific 32-bit release |

> [!TIP]
> Use **immutable tags** in CI pipelines and production Dockerfiles to guarantee
> reproducible builds.

## Emulation Setup for x86_64 Hosts

To run ARM containers on an Intel/AMD machine, install QEMU user-mode
emulation. After installing, Docker will automatically use QEMU to run ARM
images - no extra flags needed.

**Debian / Ubuntu:**

```bash
sudo apt-get install -y qemu-user-static binfmt-support
```

**Fedora:**

```bash
sudo dnf install -y qemu-user-static
```

**Arch Linux:**

```bash
sudo pacman -S qemu-user-static binfmt-qemu-static
```

## How It Works

The build is **fully automated** and runs every Monday at 08:00 UTC without manual intervention.

1. **Discover**: The pipeline checks for new Raspberry Pi OS Lite releases.
2. **Check**: It verifies if the release is already published on Docker Hub. If so, it skips the build.
3. **Download & Verify**: It downloads the official `.img` archive and verifies its SHA-256 checksum.
4. **Extract**: The official root filesystem is extracted using `libguestfs`.
5. **Build & Push**: It builds multi-arch Docker images from `scratch` and pushes them to Docker Hub.

## Use Cases

| Scenario | Example |
|----------|---------|
| **CI/CD testing** | Run your test suite against real Raspberry Pi OS in GitHub Actions |
| **Cross-compilation** | Build ARM binaries inside the container on your x86 dev machine |
| **IoT prototyping** | Develop and iterate on Pi-targeted applications without hardware |
| **Education** | Learn Linux on the same OS your Raspberry Pi runs - from any computer |
| **Packaging** | Build `.deb` packages for Raspberry Pi OS in a clean, reproducible environment |

## License

This project is licensed under the [MIT License](LICENSE).

## Code of Conduct

Please review our [Code of Conduct](.github/CODE_OF_CONDUCT.md) to understand
the expectations for behavior within the project community.

## Security Policy

For information on our security policy and reporting vulnerabilities, please
check our [Security Policy](.github/SECURITY.md).

## Contributing Guidelines

We welcome contributions! Before getting started, please read our
[Contributing Guidelines](.github/CONTRIBUTING.md) for information on how to
contribute to the project.
