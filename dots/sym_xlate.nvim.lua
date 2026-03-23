-- translate.lua
-- Translates resolved symlink paths back to symlinked paths for LSP
-- Source this file in nvim: :source /Users/janmejay/tmp/translate.lua
--
-- Create a .symlinks.lsp.json file in your project root with an array of
-- project-root-relative symlink paths. Example:
-- [
--   "lib/observo/scol/src/scol",
--   "lib/observo/sauth/src/sauth"
-- ]
--
-- The script will automatically detect what each symlink points to and
-- create the appropriate translation mappings.

local M = {}

-- Path translations (resolved_absolute -> symlink_absolute)
M.translations = {}

-- Find project root by looking for .symlinks.lsp.json or .git
function M.find_project_root(start_path)
  start_path = start_path or vim.fn.getcwd()
  local path = start_path

  while path ~= "/" do
    -- Check for .symlinks.lsp.json first
    if vim.fn.filereadable(path .. "/.symlinks.lsp.json") == 1 then
      return path
    end
    -- Fall back to .git
    if vim.fn.isdirectory(path .. "/.git") == 1 then
      return path
    end
    path = vim.fn.fnamemodify(path, ":h")
  end

  return nil
end

-- Resolve a symlink to its actual target (absolute path)
function M.resolve_symlink(symlink_path)
  -- Use realpath to get the fully resolved path
  local handle = io.popen('realpath "' .. symlink_path .. '" 2>/dev/null')
  if not handle then return nil end
  local result = handle:read("*a")
  handle:close()
  if result then
    result = result:gsub("%s+$", "") -- trim trailing whitespace/newline
    if result ~= "" then
      return result
    end
  end
  return nil
end

-- Check if a path is a symlink
function M.is_symlink(path)
  local handle = io.popen('test -L "' .. path .. '" && echo "yes" || echo "no"')
  if not handle then return false end
  local result = handle:read("*a")
  handle:close()
  return result:match("yes") ~= nil
end

-- Load translations from .symlinks.lsp.json
function M.load_translations(project_root)
  project_root = project_root or M.find_project_root()
  if not project_root then
    print("SymXlate: Could not find project root")
    return false
  end

  local json_path = project_root .. "/.symlinks.lsp.json"
  if vim.fn.filereadable(json_path) ~= 1 then
    print("SymXlate: No .symlinks.lsp.json found at " .. json_path)
    return false
  end

  -- Read and parse JSON file
  local file = io.open(json_path, "r")
  if not file then
    print("SymXlate: Could not open " .. json_path)
    return false
  end

  local content = file:read("*a")
  file:close()

  local ok, symlink_paths = pcall(vim.json.decode, content)
  if not ok or type(symlink_paths) ~= "table" then
    print("SymXlate: Invalid JSON in " .. json_path)
    return false
  end

  -- Clear existing translations
  M.translations = {}

  -- Process each symlink path
  local count = 0
  for _, relative_symlink in ipairs(symlink_paths) do
    local absolute_symlink = project_root .. "/" .. relative_symlink

    if M.is_symlink(absolute_symlink) then
      local resolved_path = M.resolve_symlink(absolute_symlink)
      if resolved_path then
        -- Map resolved -> symlinked
        M.translations[resolved_path] = absolute_symlink
        count = count + 1
      else
        print("SymXlate: Could not resolve symlink: " .. absolute_symlink)
      end
    else
      print("SymXlate: Not a symlink: " .. absolute_symlink)
    end
  end

  print(string.format("SymXlate: Loaded %d translations from %s", count, json_path))
  return true
end

-- Convert a resolved path to a symlinked path
function M.to_symlinked(path)
  if not path then return path end
  for resolved, symlinked in pairs(M.translations) do
    if path:sub(1, #resolved) == resolved then
      return symlinked .. path:sub(#resolved + 1)
    end
  end
  return path
end

-- Convert a symlinked path back to resolved path
function M.to_resolved(path)
  if not path then return path end
  for resolved, symlinked in pairs(M.translations) do
    if path:sub(1, #symlinked) == symlinked then
      return resolved .. path:sub(#symlinked + 1)
    end
  end
  return path
end

-- Convert URI to path
local function uri_to_path(uri)
  if not uri then return nil end
  if uri:sub(1, 7) == "file://" then
    local path = uri:sub(8)
    -- Decode percent-encoded characters
    path = path:gsub("%%(%x%x)", function(hex)
      return string.char(tonumber(hex, 16))
    end)
    return path
  end
  return uri
end

-- Convert path to URI
local function path_to_uri(path)
  if not path then return nil end
  -- Encode special characters (minimal encoding for paths)
  local uri = "file://" .. path:gsub(" ", "%%20")
  return uri
end

-- Transform URI using a path transformer function
local function transform_uri(uri, transformer)
  local path = uri_to_path(uri)
  if path then
    local new_path = transformer(path)
    if new_path ~= path then
      return path_to_uri(new_path)
    end
  end
  return uri
end

-- Recursively transform all URIs in a table
local function transform_uris_in_table(tbl, transformer)
  if type(tbl) ~= "table" then return tbl end

  local result = {}
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      result[k] = transform_uris_in_table(v, transformer)
    elseif type(v) == "string" and v:sub(1, 7) == "file://" then
      result[k] = transform_uri(v, transformer)
    else
      result[k] = v
    end
  end
  return result
end

-- Store original functions
local original_request = vim.lsp.buf_request
local original_notify = vim.lsp.buf_notify

-- Wrap LSP request to transform outgoing URIs (resolved -> symlinked)
vim.lsp.buf_request = function(bufnr, method, params, handler, ...)
  local transformed_params = transform_uris_in_table(params, M.to_symlinked)

  -- Wrap the handler to transform incoming URIs (symlinked -> resolved)
  local wrapped_handler
  if handler then
    wrapped_handler = function(err, result, ctx, config)
      local transformed_result = transform_uris_in_table(result, M.to_resolved)
      return handler(err, transformed_result, ctx, config)
    end
  end

  return original_request(bufnr, method, transformed_params, wrapped_handler or handler, ...)
end

-- Wrap LSP notify to transform outgoing URIs (resolved -> symlinked)
vim.lsp.buf_notify = function(bufnr, method, params, ...)
  local transformed_params = transform_uris_in_table(params, M.to_symlinked)
  return original_notify(bufnr, method, transformed_params, ...)
end

-- Override vim.uri_from_bufnr to return symlinked path
local original_uri_from_bufnr = vim.uri_from_bufnr
vim.uri_from_bufnr = function(bufnr)
  local uri = original_uri_from_bufnr(bufnr)
  return transform_uri(uri, M.to_symlinked)
end

-- Hook into the LSP client's request method directly for more coverage
local function patch_client(client)
  if client._symlink_patched then return end
  client._symlink_patched = true

  local original_client_request = client.request
  client.request = function(self, method, params, handler, bufnr, ...)
    local transformed_params = transform_uris_in_table(params, M.to_symlinked)

    local wrapped_handler
    if handler then
      wrapped_handler = function(err, result, ctx, config)
        local transformed_result = transform_uris_in_table(result, M.to_resolved)
        return handler(err, transformed_result, ctx, config)
      end
    end

    return original_client_request(self, method, transformed_params, wrapped_handler or handler, bufnr, ...)
  end

  local original_client_notify = client.notify
  client.notify = function(self, method, params, ...)
    local transformed_params = transform_uris_in_table(params, M.to_symlinked)
    return original_client_notify(self, method, transformed_params, ...)
  end
end

-- Patch all existing LSP clients
for _, client in pairs(vim.lsp.get_clients()) do
  patch_client(client)
end

-- Patch new LSP clients as they attach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("SymXlate", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      patch_client(client)
    end
  end,
})

-- Utility: Manually add a translation mapping
function M.add_translation(resolved, symlinked)
  M.translations[resolved] = symlinked
end

-- Utility: Show current translations
function M.show()
  print("Current path translations (resolved -> symlinked):")
  if next(M.translations) == nil then
    print("  (none)")
    return
  end
  for resolved, symlinked in pairs(M.translations) do
    print(string.format("  %s\n    -> %s", resolved, symlinked))
  end
end

-- Utility: Test translation on a path
function M.test(path)
  local symlinked = M.to_symlinked(path)
  local resolved = M.to_resolved(symlinked)
  print(string.format("Original:  %s", path))
  print(string.format("Symlinked: %s", symlinked))
  print(string.format("Resolved:  %s", resolved))
end

-- Utility: Reload translations from config file
function M.reload()
  M.load_translations()
end

-- Make module globally available for testing
_G.SymXlate = M

-- Auto-load translations on startup
M.load_translations()

return M
