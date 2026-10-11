#!/bin/bash
TC="$1"; PHONE="$2"
INTERP="$PHONE/glibc/ld-linux-aarch64.so.1"
RPATH="$PHONE/glibc"
n=0
while IFS= read -r -d '' f; do
  file -b "$f" | grep -q 'ELF 64-bit.*ARM aarch64' || continue
  if patchelf --print-interpreter "$f" >/dev/null 2>&1; then
    patchelf --set-interpreter "$INTERP" --set-rpath "$RPATH" "$f" && n=$((n+1)) || echo "FAILED: $f"
  else
    patchelf --set-rpath "$RPATH" "$f" 2>/dev/null && n=$((n+1)) || true
  fi
done < <(find "$TC" -path "$TC/glibc" -prune -o -type f -print0)
echo "patched $n files"
