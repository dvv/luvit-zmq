#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "uv.h"

#include "zmq.h"

#include "lua.h"
#include "lauxlib.h"

typedef int (*LUA_FN)(lua_State*);

typedef struct {
  lua_State* L;
  lua_State* X;
  uv_work_t work_req;
  LUA_FN fn;
  int cb;
} luv_work_t;

/*
 * N.B. this functions should be exportable, to save work
 */
static int lworker(lua_State* L) {
  printf("WORKING5\n");

  zmq_sleep(5);
  lua_pushstring(L, "ура!");
  lua_pushinteger(L, 5);

  printf("WORKED5\n");
  return 2;
}

static int lworker2(lua_State* L) {
  printf("WORKING2\n");

  zmq_sleep(2);
  lua_pushinteger(L, 2);
  lua_pushstring(L, "ура!");
  lua_pushboolean(L, 0);

  printf("WORKED2\n");
  return 3;
}

static const LUA_FN functions[] = {
  lworker,
  lworker2,
};

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

  int fn_index = luaL_checkinteger(L, 1);
  luaL_checktype(L, 2, LUA_TFUNCTION);

  luv_work_t* ref = malloc(sizeof(luv_work_t));
  ref->work_req.data = ref;
  ref->L = L;

  /* allocate new state */
  ref->X = luaL_newstate();
  if (ref->X == NULL) {
    return luaL_error(L, "queue: can not allocate new state");
  }

  /* store function index */
  ref->fn = functions[fn_index];
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
  { "worker2", lworker2 },
  { NULL, NULL }
};

LUALIB_API int luaopen_queue(lua_State *L) {

  lua_newtable(L);
  luaL_register(L, NULL, exports);

  // return the new module
  return 1;
}
