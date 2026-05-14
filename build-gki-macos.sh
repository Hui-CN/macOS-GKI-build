#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT_DIR=${OUT_DIR:-"$ROOT_DIR/out/macos-gki"}
LLVM_DIR=${LLVM_DIR:-/opt/homebrew/opt/llvm}
OPENSSL_DIR=${OPENSSL_DIR:-/opt/homebrew/opt/openssl@3}
BREW_BIN=${BREW_BIN:-/opt/homebrew/bin}
HOST_TOOLS_DIR="$ROOT_DIR/prebuilts/build-tools/darwin-x86/bin"
MACOS_INCLUDE_DIR="$ROOT_DIR/tools/macos-kbuild/include"
MACOS_BIN_DIR="$ROOT_DIR/tools/macos-kbuild/bin"

require_exe() {
	if [ ! -x "$1" ]; then
		echo "missing executable: $1" >&2
		exit 1
	fi
}

require_file() {
	if [ ! -f "$1" ]; then
		echo "missing file: $1" >&2
		exit 1
	fi
}

detect_jobs() {
	jobs=$(sysctl -n hw.logicalcpu 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
	case "$jobs" in
	''|*[!0-9]*|0)
		echo 1
		;;
	*)
		echo "$jobs"
		;;
	esac
}

has_jobs_arg() {
	for arg in "$@"; do
		case "$arg" in
		-j|-j[0-9]*|--jobs|--jobs=*)
			return 0
			;;
		esac
	done
	return 1
}

require_exe "$LLVM_DIR/bin/clang"
require_exe "$LLVM_DIR/bin/clang++"
require_exe "$LLVM_DIR/bin/llvm-ar"
require_file "$OPENSSL_DIR/include/openssl/opensslv.h"
require_file "$OPENSSL_DIR/lib/libcrypto.dylib"
require_exe "$HOST_TOOLS_DIR/make"
require_exe "$HOST_TOOLS_DIR/bison"
require_exe "$HOST_TOOLS_DIR/flex"
require_exe "$BREW_BIN/gsed"
require_exe "$BREW_BIN/dtc"
require_exe "$BREW_BIN/lz4"
require_file "$MACOS_INCLUDE_DIR/elf.h"
require_file "$MACOS_INCLUDE_DIR/endian.h"

export PATH="$MACOS_BIN_DIR:$LLVM_DIR/bin:$BREW_BIN:$HOST_TOOLS_DIR:$PATH"
export MAKE="$HOST_TOOLS_DIR/make"

GKI_KERNELRELEASE=${GKI_KERNELRELEASE:-6.6.129-android15-8-4k-AsLoKeExp-v1-DEV}
ANDROID_BRANCH=${ANDROID_BRANCH:-$(sed -n 's/^BRANCH=//p' "$ROOT_DIR/common/build.config.common" | head -n 1)}
KMI_GENERATION=${KMI_GENERATION:-$(sed -n 's/^KMI_GENERATION=//p' "$ROOT_DIR/common/build.config.common" | head -n 1)}
ANDROID_RELEASE=
case "$ANDROID_BRANCH" in
android-mainline)
	ANDROID_RELEASE=mainline
	;;
android[0-9][0-9]-*)
	ANDROID_RELEASE=${ANDROID_BRANCH%%-*}
	;;
esac
if [ -n "$ANDROID_RELEASE" ]; then
	if [ -n "$KMI_GENERATION" ]; then
		case "$KMI_GENERATION" in
		*[!0-9]*)
			echo "invalid KMI_GENERATION: $KMI_GENERATION" >&2
			exit 1
			;;
		esac
		KMI_LOCALVERSION="-$ANDROID_RELEASE-$KMI_GENERATION"
	else
		KMI_LOCALVERSION="-$ANDROID_RELEASE"
	fi
	mkdir -p "$OUT_DIR"
	printf '%s\n' "$KMI_LOCALVERSION" > "$OUT_DIR/localversion"
fi

[ "$#" -gt 0 ] || set -- gki_defconfig Image.gz Image.lz4

if [ -n "${JOBS:-}" ]; then
	case "$JOBS" in
	*[!0-9]*|0)
		echo "JOBS must be a positive integer: $JOBS" >&2
		exit 1
		;;
	esac
	set -- "-j$JOBS" "$@"
elif ! has_jobs_arg "$@"; then
	set -- "-j$(detect_jobs)" "$@"
fi

exec "$HOST_TOOLS_DIR/make" -C "$ROOT_DIR/common" O="$OUT_DIR" \
	ARCH=arm64 \
	LLVM=1 \
	LLVM_IAS=1 \
	HOSTCC="$LLVM_DIR/bin/clang" \
	HOSTCXX="$LLVM_DIR/bin/clang++" \
	HOSTLD="$LLVM_DIR/bin/clang" \
	HOSTAR="$LLVM_DIR/bin/llvm-ar" \
	HOSTCFLAGS="-I$MACOS_INCLUDE_DIR -I$OPENSSL_DIR/include ${HOSTCFLAGS:-}" \
	HOSTLDFLAGS="-L$OPENSSL_DIR/lib ${HOSTLDFLAGS:-}" \
	SED="$BREW_BIN/gsed" \
	DTC="$BREW_BIN/dtc" \
	KERNELRELEASE="$GKI_KERNELRELEASE" \
	"$@"
