/* SPDX-License-Identifier: GPL-2.0 */
#ifndef TOOLS_MACOS_KBUILD_ELF_H
#define TOOLS_MACOS_KBUILD_ELF_H

/*
 * macOS does not ship the Linux/glibc <elf.h> API expected by Kbuild host
 * tools. Reuse the repository's minimal musl ELF definitions without adding
 * the whole musl sysroot to the host include search path.
 */

#include "../../../prebuilts/build-tools/sysroots/x86_64-unknown-linux-musl/include/elf.h"

#endif /* TOOLS_MACOS_KBUILD_ELF_H */
