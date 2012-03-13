PATH := .:$(PATH)
WGET := wget -qct3 --no-check-certificate

CFLAGS  += -Isrc/ -Ibuild/libzmq/include/
LDFLAGS += -lstdc++ -lpthread -lrt

all: module relay

module: build/zmq.luvit

relay: build/zero-relay

build/zero-relay: src/zero-relay.c build/libzmq/src/.libs/libzmq.a
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	strip -s $@

build/zmq.luvit: src/zmq.c build/libzmq/src/.libs/libzmq.a
	$(CC) $(CFLAGS) -shared -o $@ $^ $(LDFLAGS)

src/zmq.c:
	# N.B. https://github.com/Neopallium/lua-zmq/issues/20#issuecomment-4299550
	$(WGET) https://github.com/Neopallium/lua-zmq/raw/master/src/pre_generated-zmq.nobj.c -O - \
		| sed '/^"C = ffi_load(os_lib_table/d' >$@

build/libzmq/src/.libs/libzmq.a:
	mkdir -p build
	$(WGET) https://github.com/zeromq/libzmq/tarball/master -O - | tar -xzpf - -C build
	mv build/zeromq-* build/libzmq
	( cd build/libzmq ; ./autogen.sh ; ./configure --prefix=/usr/local )
	$(MAKE) -C build/libzmq

clean:
	rm -rf build

test:
	-luvit -e '' || wget -qct3 http://luvit.io/dist/latest/ubuntu-latest/$(shell uname -m)/luvit-bundled/luvit
	-chmod a+x luvit 2>/dev/null
	luvit tests/smoke.lua
	luvit tests/send-recv.lua
	luvit tests/poll-new.lua

.PHONY: all module relay clean test
.SILENT:
