/*
 * libfipc_platform_internal.h
 *
 * libfipc internal Userland-specific defs.
 *
 * Copyright: University of Utah
 */
#ifndef LIBFIPC_PLATFORM_INTERNAL_H
#define LIBFIPC_PLATFORM_INTERNAL_H

#include <stdio.h>

#define __fipc_debug(fmt, ...) \
    printf("fipc: %s:%d\n: "fmt,__FUNCTION__,__LINE__,##__VA_ARGS__)

#define __FIPC_BUILD_BUG_ON_NOT_POWER_OF_2(x) (__FIPC_BUILD_BUG_ON((x) == 0 || (((x) & ((x) - 1)) != 0)))
#define __FIPC_BUILD_BUG_ON(x) ((void)sizeof(char[1 - 2*!!(x)]))

#endif /* LIBFIPC_PLATFORM_INTERNAL_H */
