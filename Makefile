VERSION         := master
LIBZMQ_VERSION  := 3.1.0

PATH := .:$(PATH)
WGET := wget -qct3 --no-check-certificate

CFLAGS  += $(shell luvit --cflags | sed 's/ -Werror / /;s,/luajit,,g') -Ibuild/zeromq-$(LIBZMQ_VERSION)/include/
LDFLAGS += -lstdc++

all: module

module: build/zmq.luvit

build/zmq.luvit: build/zmq.c build/zeromq-$(LIBZMQ_VERSION)/src/.libs/libzmq.a
	$(CC) $(CFLAGS) -shared -o $@ $^ $(LDFLAGS)

build/zmq.c:
	mkdir -p build
	$(WGET) https://github.com/Neopallium/lua-zmq/raw/$(VERSION)/src/pre_generated-zmq.nobj.c -O - \
		| sed '/^"C = ffi_load(os_lib_table/d' >$@

build/zeromq-$(LIBZMQ_VERSION)/src/.libs/libzmq.a:
	# requires uuid-dev
	# TODO: How to ensure they are installed in cross-platform way, if any?
	#sudo apt-get install g++ uuid-dev
	mkdir -p build
	$(WGET) http://download.zeromq.org/zeromq-$(LIBZMQ_VERSION)-beta.tar.gz -O - | tar -xzpf - -C build
	#$(WGET) https://github.com/zeromq/libzmq/tarball/master -O - | tar -xzpf - -C build
	( cd build/zeromq-$(LIBZMQ_VERSION) ; ./configure --prefix=/usr/local )
	$(MAKE) -C build/zeromq-$(LIBZMQ_VERSION)

clean:
	rm -rf build

test:
	-luvit -e '' || wget -qct3 http://luvit.io/dist/latest/ubuntu-latest/$(shell uname -m)/luvit-bundled/luvit
	-chmod a+x luvit 2>/dev/null
	luvit tests/smoke.lua

.PHONY: all module clean test
.SILENT:
