-- minetest.settings shim
if not minetest.settings then
  minetest.settings = {}
  function minetest.settings:get_bool(...)
    return minetest.setting_getbool(...)
  end
  function minetest.settings:get(...)
    return minetest.setting_get(...)
  end
end
