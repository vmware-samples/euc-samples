# Crittercism NDK Makefile

LOCAL_PATH := $(call my-dir)

# Main client program
include $(CLEAR_VARS)
LOCAL_MODULE    := crash
LOCAL_CPP_EXTENSION := .cc
LOCAL_SRC_FILES := cpp_crash.cc crash.c strdup_crash.c recursive_crash.c

LOCAL_LDLIBS := -llog

include $(BUILD_SHARED_LIBRARY)
