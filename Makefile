#VERSION := 0.1.1
VERSION := master

all: zmq

# requires uuid-dev, and libzmq-dev.
# TODO: How to ensure they are installed in cross-platform way, if any?
zmq: build/zmq.so

build/zmq.so: build/zmq.c
	#sudo apt-get install uuid-dev libzmq-dev
	gcc -fPIC -lzmq -shared -o $@ -I$(LUA_DIR) $^

build/zmq.c:
	mkdir -p build
	wget https://github.com/Neopallium/lua-zmq/raw/$(VERSION)/src/pre_generated-zmq.nobj.c -O $@
	# FIXME: lua-zmq will look for liblua, let's link libluajit
	ln -sf libluajit.so $(LUA_DIR)/liblua.so

.PHONY: all zmq
