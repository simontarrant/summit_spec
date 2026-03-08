#!/usr/bin/env bash
set -euo pipefail

{
  echo "=== Repository Structure ==="
  find . \
    -type f \
    ! -path "./node_modules/*" \
    ! -path "./.git/*" \
    ! -path "./.next/*" \
    ! -path "./dist/*" \
    ! -path "./build/*" \
    ! -path "./out/*" \
    ! -path "./coverage/*" \
    ! -name "*.log"

} | pbcopy

echo "✓ Copied to clipboard."

