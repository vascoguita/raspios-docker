#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://downloads.raspberrypi.com"

declare -A PLATFORMS=(
  ["armhf"]="linux/arm/v6,linux/arm/v7,linux/arm64"
  ["arm64"]="linux/arm64"
)

declare -A SEEN_ARCH SEEN_SUITE

for arch in "${!PLATFORMS[@]}"; do
  name="raspios_lite_${arch}"
  dates=$(curl -fsSL "${BASE_URL}/${name}/images/" \
    | grep -oP "${name}-\K\d{4}-\d{2}-\d{2}" \
    | sort -ru)

  for date in $dates; do
    dir_url="${BASE_URL}/${name}/images/${name}-${date}"
    release_file=$(curl -fsSL "${dir_url}/" \
      | grep -oP '[^"]+\.(?:zip|img\.xz)(?=")' \
      | head -n 1)

    raspios_url="${dir_url}/${release_file}"
    suite=$(echo "$release_file" | grep -oP 'raspios-\K[a-z]+')
    tags=""

    curl -fsSLI "https://hub.docker.com/v2/repositories/${DOCKERHUB_REPO}/tags/${arch}-${suite}-${date}/" \
      >/dev/null 2>&1 || tags="${arch}-${suite}-${date}"

    [[ -z "$tags" && "${GITHUB_EVENT_NAME:-}" == "schedule" ]] && {
      SEEN_ARCH[$arch]=1
      SEEN_SUITE["${arch}-${suite}"]=1
      continue
    }

    [[ -z "${SEEN_ARCH[$arch]:-}" ]] && {
      [[ "$arch" == "arm64" ]] && tags="${tags},arm64,latest" || tags="${tags},armhf"
      SEEN_ARCH[$arch]=1
    }

    [[ -z "${SEEN_SUITE[${arch}-${suite}]:-}" ]] && {
      tags="${tags},${arch}-${suite}"
      [[ "$arch" == "arm64" ]] && tags="${tags},${suite}"
      SEEN_SUITE["${arch}-${suite}"]=1
    }

    [[ -z "${tags#,}" ]] && continue

    tags=$(echo "${tags#,}" | sed "s|[^,]*|${DOCKERHUB_REPO}:&|g")

    raspios_sha256=$(curl -fsSL "${raspios_url}.sha256" | awk '{print $1}')

    jq -n -c \
      --arg platforms "${PLATFORMS[$arch]}" \
      --arg raspios_url "$raspios_url" \
      --arg raspios_sha256 "$raspios_sha256" \
      --arg tags "$tags" \
      '{platforms: $platforms, raspios_url: $raspios_url, raspios_sha256: $raspios_sha256, tags: $tags}'
  done
done | jq -sc '{include: .}'
