#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)"
ORG="dintero/renovate-config"
default="$ROOT_DIR/default.json"

groups=()
for f in "$ROOT_DIR"/group*.json; do
    [[ "$(basename "$f")" == "$(basename "$default")" ]] && continue
    [[ -e "$f" ]] || continue
    groups+=("$(basename "$f" .json)")
done

mapfile -t extends < <(jq -r '.extends[]?' "$default")

missing=()
for g in "${groups[@]}"; do
    expected_prefix="github>$ORG:$g"
    if ! printf '%s\n' "${extends[@]}" | grep -qE "^${expected_prefix}(\(|$)"; then
        missing+=("$g")
    fi
done

if [ ${#missing[@]} -eq 0 ]; then
  echo "All group files are included in $(basename "$default")"
else
  echo "Missing groups in $(basename "$default"):"
  printf '  - %s\n' "${missing[@]}"
  exit 1
fi
