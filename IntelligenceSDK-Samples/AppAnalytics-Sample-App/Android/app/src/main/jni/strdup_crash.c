#include <stddef.h>
#include <jni.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

char *static_array[] = { "str1", "str2", "str3" };

char *prepare_to_strdup_crash(char *str_to_dup) {
	strdup((char *) str_to_dup);
}

char **alloc_str_array(int len) {
	char **arr = malloc(len);
	int i = 0;

	for (i = 0; i < len; i++) {
		arr[i] = strdup(static_array[i]);
	}

	printf("crash the program %s", prepare_to_strdup_crash((char *) 0x0));

	return arr;
}

void do_strdup_crash() {
	char **arr = alloc_str_array(3);
	int i;

	for (i = 0; i < 5; i++) {
		printf("never reached due to crash in alloc_str_array");
		printf("these prints are here just to add some bulk to");
		printf("the binary.  %s", arr[i]);
	}
}
