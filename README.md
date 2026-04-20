# raspios-docker

[![Docker Hub](https://img.shields.io/docker/pulls/vascoguita/raspios)](https://hub.docker.com/r/vascoguita/raspios)
[![License MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/license/mit)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](.github/CODE_OF_CONDUCT.md)
[![CodeQL](https://github.com/vascoguita/raspios-docker/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/vascoguita/raspios-docker/actions/workflows/github-code-scanning/codeql)
[![Build](https://github.com/vascoguita/raspios-docker/actions/workflows/docker.yml/badge.svg)](https://github.com/vascoguita/raspios-docker/actions/workflows/docker.yml)

![image](https://repository-images.githubusercontent.com/989342487/1cd8280d-bb4b-48e0-99c6-ed2d65f59be3)

Automated multi-architecture builds of
[Raspberry Pi OS](https://www.raspberrypi.com/software) Docker images.

This project automatically checks for new Raspberry Pi OS *Lite* releases every
Monday, builds multi-architecture container images from the official root
filesystems (32-bit and 64-bit variants), and publishes them to Docker Hub:
[https://hub.docker.com/r/vascoguita/raspios](https://hub.docker.com/r/vascoguita/raspios).

## Docker Images :whale:

| Tag                       | Architectures               | Description                                                              |
|---------------------------|-----------------------------|--------------------------------------------------------------------------|
| `latest`, `arm64`         | `arm64`                     | Latest 64-bit release                                                    |
| `armhf`                   | `arm/v6`, `arm/v7`, `arm64` | Latest 32-bit release                                                    |
| `<suite>`, `arm64-<suite>`| `arm64`                     | Latest 64-bit release for the given Debian suite (e.g. `bookworm`, `arm64-bookworm`) |
| `armhf-<suite>`           | `arm/v6`, `arm/v7`, `arm64` | Latest 32-bit release for the given Debian suite (e.g. `armhf-bookworm`) |
| `arm64-<suite>-YYYY-MM-DD`| `arm64`                     | Specific 64-bit release by date                                          |
| `armhf-<suite>-YYYY-MM-DD`| `arm/v6`, `arm/v7`, `arm64` | Specific 32-bit release by date                                          |

> ### Note
>
> - `latest`, `arm64`, `armhf`, `<suite>`, `arm64-<suite>`, and `armhf-<suite>`
>   are **rolling tags** that always point to the most recent release for that
>   variant or suite.
> - `*-YYYY-MM-DD` tags are **immutable** and will **never change**, ensuring
>   full reproducibility.

View on Docker Hub:
[https://hub.docker.com/r/vascoguita/raspios](https://hub.docker.com/r/vascoguita/raspios)

## Automation :robot:

A GitHub Actions workflow runs every **Monday at 08:00 UTC** to detect new
Raspberry Pi OS releases. For each new release that has not yet been published
to Docker Hub, it builds and pushes the corresponding image automatically.

## Usage :bulb:

Use these images as a base for Raspberry Pi-specific containers:

```Dockerfile
FROM vascoguita/raspios:arm64

# Add your own layers here
```

Or run directly:

```bash
docker run --rm -it --platform linux/arm64 vascoguita/raspios:arm64
```

> ### Note for x86_64 Hosts
>
> If you're running this image on an x86_64 (Intel/AMD) machine, you will need
> to enable emulation via QEMU to run ARM containers.

### Dependencies for Emulation :wrench:

To run arm64 or armhf containers on x86_64 hosts, install QEMU and enable
binfmt support using your system's package manager.

- Debian/Ubuntu:

  ```bash
  sudo apt install qemu-user-static binfmt-support
  ```

- Fedora:

  ```bash
  sudo dnf install qemu-user-static binfmt-support
  ```

- Arch Linux:

  ```bash
  sudo pacman -S qemu-user-static binfmt-support
  ```

## License :memo:

This project is licensed under the [MIT License](LICENSE).

## Code of Conduct :scroll:

Please review our [Code of Conduct](.github/CODE_OF_CONDUCT.md) to understand
the expectations for behavior within the project community.

## Security Policy :lock:

For information on our security policy and reporting vulnerabilities, please
check our [Security Policy](.github/SECURITY.md).

## Contributing Guidelines :rocket:

We welcome contributions! Before getting started, please read our
[Contributing Guidelines](.github/CONTRIBUTING.md) for information on how to
contribute to the project.
