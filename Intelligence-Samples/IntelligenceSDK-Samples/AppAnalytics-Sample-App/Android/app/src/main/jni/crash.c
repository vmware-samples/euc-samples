#include <stddef.h>
#include <jni.h>
#include <pthread.h>
#include <stdio.h>
#include "log.h"

void do_recursive_crash();
void do_strdup_crash();
void do_cpp_crash();

jboolean Java_com_crittercism_errors_NativeCustomError_crash(JNIEnv* env, jclass clazz, jstring crashType) {
	const char *native_crash_type = (*env)->GetStringUTFChars(env, crashType, 0);

	LOGI("********* Native received string: %s", native_crash_type);
	if (!strcmp(native_crash_type, "do_strdup_crash")) {
		LOGI("About to call do_strdup_crash()");
		do_strdup_crash();
	} else if (!strcmp(native_crash_type, "do_recursive_crash")) {
		LOGI("About to call do_recursive_crash()");
		do_recursive_crash();
	} else if (!strcmp(native_crash_type, "do_cpp_crash")) {
		LOGI("About to call do_cpp_crash()");
		do_cpp_crash();
	}

	(*env)->ReleaseStringUTFChars(env, crashType, native_crash_type);

	return JNI_TRUE;
}
