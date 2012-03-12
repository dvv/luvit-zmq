#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "uv.h"

typedef struct {
  lua_State* L;
  uv_work_t work_req;
  int cb;
  int ab;
} luv_work_t;

/*
static void luv_work(uv_work_t* req) {
  luv_work_t* ref = req->data;
  lua_State *L = ref->L;

  int before = lua_gettop(L);
  int argc;
  lua_rawgeti(L, LUA_REGISTRYINDEX, ref->cb);
  luaL_unref(L, LUA_REGISTRYINDEX, ref->cb);

  argc = luv_process_fs_result(L, req);
  luv_acall(L, argc + 1, 0, "fs_after");
  uv_fs_req_cleanup(req);

  assert(lua_gettop(L) == before);
}
*/

static void luv_after_work(uv_work_t* req) {
  luv_work_t* ref = req->data;
  lua_State *L = ref->L;

  int before = lua_gettop(L);
  int argc;
  lua_rawgeti(L, LUA_REGISTRYINDEX, ref->ab);
  luaL_unref(L, LUA_REGISTRYINDEX, ref->ab);

  argc = luv_process_fs_result(L, req);
  luv_acall(L, argc + 1, 0, "fs_after");
  uv_fs_req_cleanup(req);

  free(ref); /* We're done with the ref object, free it */
  assert(lua_gettop(L) == before);
}

static void _work_cb(uv_work_t* req) {
  printf("WORKER!\n");
}

int luv_queue(lua_State* L) {
  int before = lua_gettop(L);

  luv_work_t* ref = malloc(sizeof(luv_work_t));
  ref->L = L;
  ref->work_req.data = ref;

  if (lua_isfunction(L, 1)) {
    lua_pushvalue(L, 1); /* Store the callback */
    ref->cb = luaL_ref(L, LUA_REGISTRYINDEX);
  }
  if (lua_isfunction(L, 2)) {
    lua_pushvalue(L, 2); /* Store the afterback */
    ref->ab = luaL_ref(L, LUA_REGISTRYINDEX);
  }

  assert(lua_gettop(L) == before);

  if (uv_queue_work(luv_get_loop(L), &ref->work_req, _work_cb, luv_after_work)) {
    uv_err_t err = uv_last_error(luv_get_loop(L));
    luv_push_async_error(L, err, "queue");
    return lua_error(L);
  }

  return 0;
}
