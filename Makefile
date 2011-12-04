VERSION         := master
LIBZMQ_VERSION  := 2.1.10

all: zmq

# requires uuid-dev
# TODO: How to ensure they are installed in cross-platform way, if any?
zmq: build/zmq.so

build/zmq.so: build/zmq.c build/libzmq/src/.libs/libzmq.a
	$(CC) -fPIC -shared -o $@ -I$(LUA_DIR) -Ibuild/libzmq/include $^ -luuid -lstdc++ -lrt -lpthread

build/zmq.c:
	mkdir -p build
	wget https://github.com/Neopallium/lua-zmq/raw/$(VERSION)/src/pre_generated-zmq.nobj.c -O $@

build/libzmq/src/.libs/libzmq.a:
	#sudo apt-get install uuid-dev
	mkdir -p build
	wget http://download.zeromq.org/zeromq-$(LIBZMQ_VERSION).tar.gz -O - | tar -xzpf - -C build
	mv build/zeromq-$(LIBZMQ_VERSION) build/libzmq
	( cd build/libzmq ; ./configure --prefix=/usr/local )
	make -C build/libzmq

.PHONY: all zmq
