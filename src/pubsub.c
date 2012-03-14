#include <stdint.h>
#include <stdio.h>
#include <zmq.h>

#include <lua.h>
#include <lauxlib.h>

static int lzmq_init(lua_State *L) {

  uint32_t id = luaL_checkint(L, 1);
  void *context = zmq_init(id);

  lua_pushinteger(L, context);

  return 1;
}

////////////////////////////////////////////////////////////////////////////////

static const luaL_reg exports[] = {
  {"init", lzmq_init},
  /*{"close", lzmq_close},
  {"term", lzmq_term},
  {"socket", lzmq_socket},
  {"bind", lzmq_bind},
  {"connect", lzmq_connect},
  {"send", lzmq_send},
  {"recv", lzmq_recv},
  {"msg_init", lzmq_msg_init},
  {"msg_close", lzmq_msg_close},
  {"poll", lzmq_poll},
  {"setopt", lzmq_setsockopt},
  {"getopt", lzmq_getsockopt},*/
  {NULL, NULL}
};

LUALIB_API int luaopen_zmq(lua_State *L) {

  lua_newtable(L);
  luaL_register(L, NULL, exports);

  return 1;
}
