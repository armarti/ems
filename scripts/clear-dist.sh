#!/usr/bin/env bash

THIS_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
DIST_DIR="$(realpath "$THIS_DIR"/../dist)"
echo "Clearing $DIST_DIR/*"
rm -rf "$DIST_DIR"/*
echo "Done."
