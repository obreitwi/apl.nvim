--- Perform health checks.
---@module apl.health
---@usage :checkhealth apl
---@local

-- local install = require 'apl.install'
local lang = require 'apl.lang'
local config = require 'apl.config'
local extensions = require 'apl.extensions'

local M = {}

local function check_nvim_version()
  local supported = vim.fn.has 'nvim-0.7' == 1
  if not supported then
    vim.health.error 'apl.nvim needs nvim version 0.7 or higher.'
    vim.health.info 'if you are unable to upgrade, use the `0.6-compat` branch'
  else
    local v = vim.version()
    vim.health.ok(string.format('nvim version %d.%d.%d', v.major, v.minor, v.patch))
  end
end

-- local function check_classes_installed()
--   local class_path = install.check()
--   if not class_path then
--     vim.health.error 'apl classes are not installed.'
--     vim.health.info 'use `ensure_installed = true` in the apl setup function'
--   else
--     vim.health.ok('apl classes are installed: ' .. class_path)
--   end
-- end

local function check_keymaps()
  if vim.tbl_count(config.keymaps) == 0 then
    vim.health.info 'no keymaps defined'
  else
    vim.health.ok 'keymaps are defined'
  end
end

-- local function check_documentation()
--   local doc = config.documentation
--   if not doc.cmd then
--     vim.health.info 'using HelpBrowser for documentation'
--   else
--     local exe_path = vim.fn.exepath(doc.cmd)
--     if exe_path ~= '' then
--       vim.health.ok(doc.cmd)
--     end
--     if doc.args then
--       local vin = false
--       local vout = false
--       for _, arg in ipairs(doc.args) do
--         if arg == '$1' then
--           vin = true
--         elseif arg == '$2' then
--           vout = true
--         end
--       end
--       if vin and vout then
--         vim.health.ok(vim.inspect(doc.args))
--       elseif vout and not vin then
--         vim.health.error 'argument list is missing input placeholder ($1)'
--       elseif vin and not vout then
--         vim.health.error 'argument list is missing output placeholder ($2)'
--       else
--         vim.health.error 'argument list is missing both input and output placeholders ($1/$2)'
--       end
--     end
--     if doc.on_open then
--       vim.health.info 'using external function for on_open'
--     end
--     if doc.on_select then
--       vim.health.info 'using external function for on_select'
--     end
--   end
-- end

-- local function check_lang()
--   local ok, ret = pcall(lang.find_lang_executable)
--   if ok then
--     vim.health.ok('lang executable: ' .. ret)
--   else
--     vim.health.error(ret)
--   end
-- end

local function check_extensions()
  local installed = {}
  for name, _ in pairs(extensions.manager) do
    installed[#installed + 1] = name
  end
  table.sort(installed)
  for _, name in ipairs(installed) do
    local health_check = extensions._health[name]
    if health_check then
      vim.health.start(string.format('extension: "%s"', name))
      health_check()
      local link = extensions._linked[name]
      if link then
        vim.health.ok(string.format('installed classes "%s"', link))
      else
        vim.health.ok 'no classes to install'
      end
    else
      vim.health.ok(string.format('No vim.health check for "%s"', name))
    end
  end
end

function M.check()
  vim.health.start 'apl'
  check_nvim_version()
  -- check_lang()
  -- check_classes_installed()
  check_keymaps()
  -- vim.health.start 'apl documentation'
  -- check_documentation()
  vim.health.start 'apl extensions'
  check_extensions()
end

return M
