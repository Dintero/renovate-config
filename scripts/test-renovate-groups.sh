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

missing_in_extends=()
for g in "${groups[@]}"; do
    expected_prefix="github>$ORG:$g"
    if ! printf '%s\n' "${extends[@]}" | grep -qE "^${expected_prefix}(\(|$)"; then
        missing_in_extends+=("$g")
    fi
done

if [ ${#missing_in_extends[@]} -eq 0 ]; then
  echo "All group files are included in $(basename "$default")"
else
  echo "Missing groups in $(basename "$default"):"
  printf '  - %s\n' "${missing_in_extends[@]}"
  exit 1
fi

missing_file=()
for e in "${extends[@]}"; do
    if echo "$e" | grep -q "^github>$ORG:"; then
        g=$(echo "$e" | sed -E "s|^github>$ORG:([^(]+).*|\1|")
        [[ -f "$ROOT_DIR/$g.json" ]] || missing_file+=("$g")
    fi
done

if [ ${#missing_file[@]} -eq 0 ]; then
  echo "All extends entries exist in $(basename "$default")"
else
  echo "Extends entries referencing non-existent files in $(basename "$default"):"
  printf '  - %s\n' "${missing_file[@]}"
  exit 1
fi
