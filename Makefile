#VERSION := 0.1.1
VERSION := master

all: zmq

# requires cmake, uuid-dev, and libzmq-dev.
# TODO: How to ensure they are installed in cross-platform way, if any?
zmq: build/lua-zmq/build/zmq.so

build/lua-zmq/build/zmq.so: build/lua-zmq/build
	#apt-get install uuid-dev libzmq-dev cmake
	( cd $^ ; LUA_DIR=$(LUA_DIR) cmake .. )
	make -C $^

build/lua-zmq/build:
	mkdir -p build
	wget https://github.com/Neopallium/lua-zmq/tarball/$(VERSION) -O - | tar -xzpf - -C build
	mv build/Neopallium-lua-* build/lua-zmq
	# FIXME: lua-zmq will look for liblua, let's link libluajit
	ln -sf libluajit.so $(LUA_DIR)/liblua.so
	mkdir -p $@

.PHONY: all zmq
