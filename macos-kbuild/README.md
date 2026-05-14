# macOS native GKI build

This directory contains host-only shims for building the arm64 GKI kernel with
native macOS tools and Homebrew LLVM, without Bazel.

## Prerequisites

- Xcode Command Line Tools or Xcode
- Homebrew LLVM at `/opt/homebrew/opt/llvm`
- Homebrew OpenSSL at `/opt/homebrew/opt/openssl@3`
- Homebrew `dtc`, `lz4`, and GNU `sed` (`gsed`)
- The repository `prebuilts/build-tools/darwin-x86/bin` tools

## Build

```sh
tools/build-gki-macos.sh
```

By default this builds:

```sh
gki_defconfig Image.gz Image.lz4
```

The output directory defaults to:

```sh
out/macos-gki
```

The script automatically passes `-jN`, where `N` is the detected logical CPU
count. Override paths, jobs, or targets when needed:

```sh
JOBS=8 OUT_DIR=/tmp/gki-out tools/build-gki-macos.sh Image.gz
tools/build-gki-macos.sh -j8 Image.gz
LLVM_DIR=/opt/homebrew/opt/llvm OPENSSL_DIR=/opt/homebrew/opt/openssl@3 tools/build-gki-macos.sh
```

## Notes

Kbuild host tools assume Linux-flavored headers and GNU userland in a few
places. The shims here provide only the narrow compatibility layer needed on
macOS:

- `elf.h`
- `endian.h`
- selected `asm/` UAPI wrappers used before generated headers exist
- `unistd.h` UUID typedef isolation
- `sed` wrapper to GNU sed
