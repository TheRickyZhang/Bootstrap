return {
  dir = "~/Projects/vimficiency",
  name = "vimficiency",
  lazy = false,
  config = function()
    require("vimficiency").setup({ })

    -- require("vimficiency").setup({
    --   default_keyboard = 2,
    -- })

    -- local ffi = require("vimficiency.ffi")
    -- require("vimficiency").setup({
    --     default_keyboard = 2,  -- QWERTY
    --     weights = {
    --         w_key = 1.5,
    --         w_same_finger = 0.3,
    --     },
    --     keys = {
    --         [ffi.Key.Space] = {
    --             hand = ffi.Hand.Left,
    --             finger = ffi.Finger.Lt,
    --             cost = 0.2,
    --         },
    --     },
    -- })
  end
}
