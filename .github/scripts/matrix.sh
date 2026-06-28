#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://downloads.raspberrypi.com"

declare -A PLATFORMS=(
  ["armhf"]="linux/arm/v6,linux/arm/v7,linux/arm64"
  ["arm64"]="linux/arm64"
)

declare -A SEEN_ARCH SEEN_SUITE

die() { echo "matrix.sh: $1" >&2; exit 1; }
fetch() { curl -fsSL --retry 3 --retry-delay 2 --connect-timeout 15 "$@"; }
add_tag() { tags="${tags:+$tags,}${DOCKERHUB_REPO}:$1"; }

tag_published() {
  local code
  code=$(curl -sSL -I -o /dev/null -w '%{http_code}' \
    --retry 3 --retry-delay 2 --connect-timeout 15 "$1" || true)
  case "$code" in
    200) return 0 ;;
    404) return 1 ;;
    *) die "unexpected HTTP ${code} for $1" ;;
  esac
}

[[ "${DOCKERHUB_REPO:-}" =~ ^[^/]+/[^/]+$ ]] ||
  die "DOCKERHUB_REPO must be set to <user>/<repo>, got '${DOCKERHUB_REPO:-}'"

for arch in "${!PLATFORMS[@]}"; do
  name="raspios_lite_${arch}"

  readarray -t dates < <(fetch "${BASE_URL}/${name}/images/" \
    | grep -oP "${name}-\K\d{4}-\d{2}-\d{2}" \
    | sort -ru)

  [[ ${#dates[@]} -eq 0 ]] && die "no dated images found for ${name}"

  for date in "${dates[@]}"; do
    dir_url="${BASE_URL}/${name}/images/${name}-${date}"

    release_file=$(fetch "${dir_url}/" \
      | grep -m1 -oP '[^"/]+\.(?:zip|img\.xz)(?=")') ||
      die "no release image found under ${dir_url}/"

    raspios_url="${dir_url}/${release_file}"

    suite=$(echo "$release_file" | grep -oP 'raspios-\K[a-z]+') ||
      die "could not parse suite from ${release_file}"

    tags=""

    tag_url="https://hub.docker.com/v2/repositories/${DOCKERHUB_REPO}/tags/${arch}-${suite}-${date}/"
    tag_published "$tag_url" || add_tag "${arch}-${suite}-${date}"

    if [[ -z "$tags" && "${GITHUB_EVENT_NAME:-}" == "schedule" ]]; then
      SEEN_ARCH[$arch]=1
      SEEN_SUITE["${arch}-${suite}"]=1
      continue
    fi

    if [[ -z "${SEEN_ARCH[$arch]:-}" ]]; then
      if [[ "$arch" == "arm64" ]]; then
        add_tag arm64
        add_tag latest
      else
        add_tag armhf
      fi
      SEEN_ARCH[$arch]=1
    fi

    if [[ -z "${SEEN_SUITE[${arch}-${suite}]:-}" ]]; then
      add_tag "${arch}-${suite}"
      [[ "$arch" == "arm64" ]] && add_tag "${suite}"
      SEEN_SUITE["${arch}-${suite}"]=1
    fi

    [[ -z "$tags" ]] && continue

    raspios_sha256=$(fetch "${raspios_url}.sha256" | awk '{print $1}') ||
      die "could not fetch checksum from ${raspios_url}.sha256"

    [[ "$raspios_sha256" =~ ^[0-9a-f]{64}$ ]] ||
      die "invalid checksum for ${raspios_url}"

    jq -n -c \
      --arg platforms "${PLATFORMS[$arch]}" \
      --arg test_platform "${PLATFORMS[$arch]%%,*}" \
      --arg raspios_url "$raspios_url" \
      --arg raspios_sha256 "$raspios_sha256" \
      --arg tags "$tags" \
      --arg test_tag "${tags%%,*}" \
      '{platforms: $platforms, test_platform: $test_platform, raspios_url: $raspios_url, raspios_sha256: $raspios_sha256, tags: $tags, test_tag: $test_tag}'
  done
done | jq -sc '{include: .}'
