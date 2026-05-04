#pragma once

#if defined(__APPLE__) && defined(__clang__) && !defined(R_EXT_BOOLEAN_H_)
#define MFRMR_RESTORE_APPLE_MACRO
#undef __APPLE__
#include <R_ext/Boolean.h>
#define __APPLE__ 1
#undef MFRMR_RESTORE_APPLE_MACRO
#endif
