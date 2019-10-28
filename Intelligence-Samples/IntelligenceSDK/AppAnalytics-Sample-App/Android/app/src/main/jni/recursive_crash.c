#include <stddef.h>
#include <jni.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <android/log.h>
#include "log.h"

void recursive_function(int crashDepth) {
	if (crashDepth) {
		LOGI("recursive_function: %d", crashDepth);
		recursive_function(crashDepth - 1);
	} else {
		int *null_pointer = (int *) 0x0;
		LOGI("recursive_function: %d", *null_pointer);
	}
}

void do_recursive_crash() {
	recursive_function(5);
}
