VERSION         := master
LIBZMQ_VERSION  := 2.1.10

WGET            := wget --no-check-certificate

OS ?= $(shell uname)
ifeq ($(OS),Darwin)
SOEXT := dylib
else ifeq ($(OS),Windows)
SOEXT := dll
else
LDFLAGS += -luuid -lrt -lpthread
SOEXT := so
endif

CFLAGS  += $(shell pkg-config --cflags lua)
CFLAGS  += -Ibuild/libzmq/include/
LDFLAGS += -lstdc++
LDFLAGS += $(shell pkg-config --libs lua)

all: zmq

# requires uuid-dev
# TODO: How to ensure they are installed in cross-platform way, if any?
zmq: build/zmq.$(SOEXT)

build/zmq.$(SOEXT): build/zmq.c build/libzmq/src/.libs/libzmq.a
	$(CC) $(CFLAGS) -fPIC -shared -o $@ -I$(LUA_DIR) -Ibuild/libzmq/include $^ $(LDFLAGS)

build/zmq.c:
	mkdir -p build
	$(WGET) https://github.com/Neopallium/lua-zmq/raw/$(VERSION)/src/pre_generated-zmq.nobj.c -O $@

build/libzmq/src/.libs/libzmq.a:
	#sudo apt-get install uuid-dev
	mkdir -p build
	$(WGET) http://download.zeromq.org/zeromq-$(LIBZMQ_VERSION).tar.gz -O - | tar -xzpf - -C build
	mv build/zeromq-$(LIBZMQ_VERSION) build/libzmq
	( cd build/libzmq ; ./configure --prefix=/usr/local )
	$(MAKE) -C build/libzmq

clean:
	rm -rf build

.PHONY: all zmq
