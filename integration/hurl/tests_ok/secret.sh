#!/bin/bash
set -Eeuo pipefail

rm -rf build/secret

hurl --very-verbose \
    --secret a=secret1 \
    --secret b=secret2 \
    --secret c=12345678 \
    --report-html build/secret \
    tests_ok/secret.hurl

secrets=("secret1" "secret2" "secret3" "12345678")

files=$(find build/secret/*.html build/secret/**/*.html tests_ok/secret.err.pattern)

for secret in "${secrets[@]}"; do
  for file in $files; do
    # Don't search leaks in sources
    if [[ "$file" == *source.html ]]; then
      continue
    fi
    if grep -q "$secret" "$file"; then
        echo "Secret <$secret> have leaked in $file"
        exit 1
    fi
  done
done

