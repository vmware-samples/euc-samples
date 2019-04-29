#include <android/log.h>

#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, "testapp-ndk", __VA_ARGS__))
