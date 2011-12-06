VERSION         := master
LIBZMQ_VERSION  := 2.1.10

WGET            := wget -qct3 --no-check-certificate

OS ?= $(shell uname)
ifeq ($(OS),Darwin)
SOEXT := dylib
else ifeq ($(OS),Windows)
SOEXT := dll
else
LDFLAGS += -luuid -lrt -lpthread
SOEXT := so
endif

#CFLAGS  += $(shell pkg-config --cflags lua)
CFLAGS  += -I$(LUA_DIR) -Ibuild/zeromq-$(LIBZMQ_VERSION)/include/
#LDFLAGS += $(shell pkg-config --libs lua)
LDFLAGS += -lstdc++

all: module

module: build/zmq.luvit

build/zmq.luvit: build/zmq.c build/zeromq-$(LIBZMQ_VERSION)/src/.libs/libzmq.a
	$(CC) $(CFLAGS) -fPIC -shared -o $@ $^ $(LDFLAGS)
	mv build/zmq.$(SOEXT) $@

build/zmq.c:
	mkdir -p build
	$(WGET) https://github.com/Neopallium/lua-zmq/raw/$(VERSION)/src/pre_generated-zmq.nobj.c -O $@

build/zeromq-$(LIBZMQ_VERSION)/src/.libs/libzmq.a:
	# requires uuid-dev
	# TODO: How to ensure they are installed in cross-platform way, if any?
	#sudo apt-get install uuid-dev
	mkdir -p build
	$(WGET) http://download.zeromq.org/zeromq-$(LIBZMQ_VERSION).tar.gz -O - | tar -xzpf - -C build
	( cd build/zeromq-$(LIBZMQ_VERSION) ; ./configure --prefix=/usr/local )
	$(MAKE) -C build/zeromq-$(LIBZMQ_VERSION)

clean:
	rm -rf build

.PHONY: all module clean
.SILENT:
