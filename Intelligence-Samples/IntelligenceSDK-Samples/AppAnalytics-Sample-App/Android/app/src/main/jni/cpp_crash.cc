#include <stddef.h>
#include <jni.h>
#include <string.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include "log.h"

extern "C" void do_cpp_crash();

class World {
public:
	int *get_pointer() {
		return 0x0;
	}
};

class Hello {
	std::string _str;

public:
	Hello(std::string str) : _str(str) {}

	void print_str() {
		World world;
		std::cout << _str;
		std::cout << *world.get_pointer();
	}
};

void do_cpp_crash() {
	LOGI("in do_cpp_crash");
	Hello hello("hello world");
	hello.print_str();
}
