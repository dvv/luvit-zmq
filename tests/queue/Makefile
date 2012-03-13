LUADIR := ../../../luvit/deps/luajit/src
UVDIR  := ../../../luvit/deps/uv
ZMQDIR := ../../build/libzmq

all: queue.luvit
	#valgrind luvit -i test.lua
	luvit -i test.lua

queue: queue.c $(UVDIR)/uv.a
	$(CC) -pipe -O2 -g -DEV_MULTIPLICITY=0 -I$(LUADIR) -I$(UVDIR)/include -I$(ZMQDIR)/include -o $@ $^ -lpthread -lm -lrt
	./$@

queue.luvit: unblock.c $(ZMQDIR)/src/.libs/libzmq.a
	$(CC) -g -pipe -shared \
		-I$(LUADIR) -I$(UVDIR)/include -I$(ZMQDIR)/include \
		-o $@ $^
