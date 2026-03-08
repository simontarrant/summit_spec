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

  echo
  echo
  echo "=== .claude Directory Files ==="

  if [ -d ".claude" ]; then
    for file in .claude/*; do
      if [ -f "$file" ]; then
        echo
        echo "━━━ $(basename "$file") ━━━"
        cat "$file"
      fi
    done
  else
    echo "(no .claude directory found)"
  fi
} | pbcopy

echo "✓ Copied to clipboard."

