#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*OatmealSettingsCallback)(int32_t action, int32_t index, const char* value);

void oatmeal_swift_show_settings(const char* shortcuts, int32_t theme, int32_t position,
                                 double duration, int32_t launch_on_login,
                                 OatmealSettingsCallback callback);

#ifdef __cplusplus
}
#endif
