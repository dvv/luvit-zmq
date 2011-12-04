VERSION         := master
LIBZMQ_VERSION  := 2.1.10

all: zmq

# requires uuid-dev
# TODO: How to ensure they are installed in cross-platform way, if any?
zmq: build/zmq.so

ROOT    := $(shell pwd)

build/zmq.so: build/zmq.c build/libzmq/src/.libs/libzmq.so
	#sudo apt-get install uuid-dev
	$(CC) -fPIC -shared -o $@ -Wl,-rpath,$(ROOT)/build/libzmq/src/.libs -I$(LUA_DIR) -Ibuild/libzmq/include -L$(ROOT)/build/libzmq/src/.libs $^ -luuid -lstdc++ -lrt -lpthread

build/zmq.c:
	mkdir -p build
	wget https://github.com/Neopallium/lua-zmq/raw/$(VERSION)/src/pre_generated-zmq.nobj.c -O $@
	# FIXME: lua-zmq will look for liblua, let's link libluajit
	#ln -sf libluajit.so $(LUA_DIR)/liblua.so

build/libzmq/src/.libs/libzmq.so: build/libzmq
	( cd $^ ; ./configure --prefix=/usr/local )
	make -C $^

build/libzmq:
	mkdir -p build
	wget http://download.zeromq.org/zeromq-$(LIBZMQ_VERSION).tar.gz -O - | tar -xzpf - -C build
	mv build/zeromq-$(LIBZMQ_VERSION) $@

.PHONY: all zmq
