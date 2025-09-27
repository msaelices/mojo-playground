#!/bin/bash

# Script to run all .mojo files and report only failures

find . -name "*.mojo" -type f -not -path "./.pixi/*" | while read file; do
    if ! mojo "$file" > /dev/null 2>&1; then
        echo "Failed: $file"
    fi
done
