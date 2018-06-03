#!/usr/bin/env bash

THIS_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
BUILD_DIR="$(realpath "$THIS_DIR"/../build)"
echo "Clearing $BUILD_DIR/*"
rm -rf "$BUILD_DIR"/*
echo "Done."
