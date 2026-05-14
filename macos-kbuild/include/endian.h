/* SPDX-License-Identifier: GPL-2.0 */
#ifndef TOOLS_MACOS_KBUILD_ENDIAN_H
#define TOOLS_MACOS_KBUILD_ENDIAN_H

/*
 * Small Linux-compatible endian shim for host tools built on macOS.
 * Darwin has the byte-swap primitives, but not the <endian.h> spellings
 * used by Linux Kbuild host utilities.
 */

#include <libkern/OSByteOrder.h>
#include <machine/endian.h>
#include <stdint.h>

#ifndef htobe16
#define htobe16(x) OSSwapHostToBigInt16((uint16_t)(x))
#endif
#ifndef htole16
#define htole16(x) OSSwapHostToLittleInt16((uint16_t)(x))
#endif
#ifndef be16toh
#define be16toh(x) OSSwapBigToHostInt16((uint16_t)(x))
#endif
#ifndef le16toh
#define le16toh(x) OSSwapLittleToHostInt16((uint16_t)(x))
#endif

#ifndef htobe32
#define htobe32(x) OSSwapHostToBigInt32((uint32_t)(x))
#endif
#ifndef htole32
#define htole32(x) OSSwapHostToLittleInt32((uint32_t)(x))
#endif
#ifndef be32toh
#define be32toh(x) OSSwapBigToHostInt32((uint32_t)(x))
#endif
#ifndef le32toh
#define le32toh(x) OSSwapLittleToHostInt32((uint32_t)(x))
#endif

#ifndef htobe64
#define htobe64(x) OSSwapHostToBigInt64((uint64_t)(x))
#endif
#ifndef htole64
#define htole64(x) OSSwapHostToLittleInt64((uint64_t)(x))
#endif
#ifndef be64toh
#define be64toh(x) OSSwapBigToHostInt64((uint64_t)(x))
#endif
#ifndef le64toh
#define le64toh(x) OSSwapLittleToHostInt64((uint64_t)(x))
#endif

#endif /* TOOLS_MACOS_KBUILD_ENDIAN_H */
