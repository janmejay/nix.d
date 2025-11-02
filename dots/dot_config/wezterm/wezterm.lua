local wezterm = require('wezterm')
local act = wezterm.action
local env = require('env')

-- no q, w, n
local alt_map = {}
if env.os == 'mac' then
  local all_characters = [[`1234567890-=ertyuiop[]\asdfghjkl;'zxcvbm,./]]
  for i = 1, #all_characters do
    local ch = all_characters:sub(i, i);
    table.insert(alt_map, {key = ch, mods = 'CMD', action = act.SendKey {key = ch, mods = 'ALT'}})
  end
  table.insert(alt_map, {key = 'Backspace', mods = 'CMD', action = act.SendKey {key = 'Backspace', mods = 'ALT'}})
end

return {
  keys = alt_map,
  enable_tab_bar = false,
  window_decorations = 'RESIZE',
  font_size = 13,
}
