#!/usr/bin/env bash
set -euo pipefail
idlike="$({ . /etc/os-release; echo "${ID_LIKE:-$ID}"; } 2>/dev/null | tr '[:upper:]' '[:lower:]')"

case "$idlike" in
  *arch*|*omarchy*|*artix*) exec "$syncScripts/importArch.sh" "$@" ;;
  *debian*|*ubuntu*)        exec "$syncScripts/importUbuntu.sh" "$@" ;;
  *) echo "unsupported distro: $idlike"; exit 1 ;;
esac
