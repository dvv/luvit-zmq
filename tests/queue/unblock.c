#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "uv.h"

#include "lua.h"
#include "lauxlib.h"

////////////////////////////////////////////////////////////////////////////////

#include "zmq.h"

static int lworker(lua_State* L) {
  zmq_sleep(5);
  lua_pushstring(L, "ура!");
  lua_pushinteger(L, 5);
  return 2;
}

static int lworker2(lua_State* L) {
  zmq_sleep(2);
  lua_pushinteger(L, 2);
  lua_pushstring(L, "ура!");
  lua_pushboolean(L, 0);
  return 3;
}

////////////////////////////////////////////////////////////////////////////////

typedef struct {
  lua_State* L;
  lua_State* X;
  uv_work_t work_req;
  lua_CFunction fn;
  int cb;
} luv_work_t;

static void worker(uv_work_t* req) {
  luv_work_t* ref = req->data;
  ref->fn(ref->X);
}

static void after_work(uv_work_t* req) {
  luv_work_t* ref = req->data;
  lua_State *L = ref->L;

  int before = lua_gettop(L);

  /* load the callback and arguments */
  int argc = lua_gettop(ref->X);
  lua_rawgeti(L, LUA_REGISTRYINDEX, ref->cb);
  luaL_unref(L, LUA_REGISTRYINDEX, ref->cb);
  lua_xmove(ref->X, L, argc);
  assert(lua_gettop(ref->X) == 0);
  /* call back */
  luv_acall(L, argc, 0, "after_work");

  assert(lua_gettop(L) == before);

  /*cleanup */
  lua_close(ref->X);
  free(ref);
}

int luv_queue(lua_State* L) {

  int before = lua_gettop(L);

  /* check arguments */
  luaL_checktype(L, 1, LUA_TFUNCTION);
  luaL_checktype(L, 2, LUA_TFUNCTION);

  /* allocate worker object */
  luv_work_t* ref = malloc(sizeof(luv_work_t));
  ref->work_req.data = ref;
  ref->L = L;

  /* store worker function */
  ref->fn = lua_tocfunction(L, 1);
  if (ref->fn == NULL) {
    return luaL_error(L, "queue: can not find worker function");
  }

  /* allocate new state */
  ref->X = luaL_newstate();
  if (ref->X == NULL) {
    return luaL_error(L, "queue: can not allocate new state");
  }

  /* store callback */
  lua_pushvalue(L, 2);
  ref->cb = luaL_ref(L, LUA_REGISTRYINDEX);

  if (uv_queue_work(luv_get_loop(L), &ref->work_req, worker, after_work)) {
    uv_err_t err = uv_last_error(luv_get_loop(L));
    return luaL_error(L, "queue: %s", uv_strerror(err));
    //luv_push_async_error(L, err, "queue");
    //return lua_error(L);
  }

  assert(lua_gettop(L) == before);

  return 0;
}

////////////////////////////////////////////////////////////////////////////////

static const luaL_reg exports[] = {
  { "queue", luv_queue },
  { "worker", lworker },
  { "worker2", lworker2 },
  { NULL, NULL }
};

LUALIB_API int luaopen_queue(lua_State *L) {

  lua_newtable(L);
  luaL_register(L, NULL, exports);

  // return the new module
  return 1;
}
