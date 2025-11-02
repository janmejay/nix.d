local wezterm = require('wezterm')
local env = {}

if wezterm.target_triple:find('darwin') then
  env.os = 'mac'
  env.mod = 'CMD'
else
  env.os = 'linux'
  env.mod = 'ALT'
end

return env
