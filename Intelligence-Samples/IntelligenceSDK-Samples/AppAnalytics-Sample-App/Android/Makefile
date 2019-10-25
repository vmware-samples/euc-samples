NDK_HOME:=$(abspath $(dir $(shell which ndk-build)))

all: app-ndk

app-ndk: local.properties
	./gradlew :app:assembleNdkDebug

.PHONY: local.properties clean

clean: local.properties
	./gradlew :app:clean

local.properties: $(NDK_HOME)
	grep -sqE '^ndk\.dir' $@ || echo ndk.dir=$(NDK_HOME) >> $@

