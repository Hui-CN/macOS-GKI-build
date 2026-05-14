/* SPDX-License-Identifier: GPL-2.0 */
#ifndef TOOLS_MACOS_KBUILD_UNISTD_H
#define TOOLS_MACOS_KBUILD_UNISTD_H

/*
 * Darwin's <unistd.h> exposes a uuid_t typedef that collides with the Linux
 * uuid_t structure used by scripts/mod/file2alias.c. Keep Darwin prototypes
 * parseable under a private name, then let Linux host tools define uuid_t.
 */
#ifdef __APPLE__
#define uuid_t darwin_uuid_t
#include_next <unistd.h>
#undef uuid_t
#else
#include_next <unistd.h>
#endif

#endif /* TOOLS_MACOS_KBUILD_UNISTD_H */
