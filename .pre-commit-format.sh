#!/bin/bash
# Pre-commit hook to check mojo formatting
# Runs mojo format and fails if files were reformatted

set -e

# Create a temp directory for comparison
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Copy files to temp dir
for file in "$@"; do
  mkdir -p "$TEMP_DIR/$(dirname "$file")"
  cp "$file" "$TEMP_DIR/$file"
done

# Format original files
pixi run mojo format "$@"

# Compare each file
for file in "$@"; do
  if ! diff -q "$file" "$TEMP_DIR/$file" > /dev/null 2>&1; then
    echo "$file was not formatted correctly"
    # Restore original
    cp "$TEMP_DIR/$file" "$file"
    exit 1
  fi
done

exit 0
