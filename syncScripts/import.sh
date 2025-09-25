#!/usr/bin/env bash
set -euo pipefail
d="$(cd "$(dirname "$0")"; pwd)"
idlike="$({ . /etc/os-release; echo "${ID_LIKE:-$ID}"; } 2>/dev/null | tr '[:upper:]' '[:lower:]')"

case "$idlike" in
  *arch*|*omarchy*|*artix*) exec "$d/importArch.sh" "$@" ;;
  *debian*|*ubuntu*)        exec "$d/importUbuntu.sh" "$@" ;;
  *) echo "unsupported distro: $idlike"; exit 1 ;;
esac
