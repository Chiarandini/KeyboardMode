local M = {}

local keyboard_mode = false
local config = {
  default_layout = 'Canadian',
  alternate_layout = 'Hiragana',
  ignored_filetypes = {
    'TelescopePrompt',
    'DressingSelect',
    'DressingInput',
    'noice',
    'notify',
    'prompt',
    'Oil'
  },
  available_layouts = {}
}

-- Check if keyboardSwitcher is installed
local function check_keyboard_switcher()
  return vim.fn.executable('keyboardSwitcher') == 1
end

-- Get available keyboard layouts
local function get_available_layouts()
  if not check_keyboard_switcher() then
    return {}
  end

  local result = vim.system({'keyboardSwitcher', 'list'}):wait()
  if result.code ~= 0 then
    return {}
  end

  local layouts = {}
  for line in result.stdout:gmatch('[^\n]+') do
    local layout = line:match('^%s*(.-)%s*$')
    if layout and layout ~= '' and layout ~= 'Available Layouts:' then
      table.insert(layouts, layout)
    end
  end
  return layouts
end

-- Validate if a layout exists
local function validate_layout(layout_name)
  if not layout_name then return false end

  for _, available in ipairs(config.available_layouts) do
    if available == layout_name then
      return true
    end
  end
  return false
end

-- Check if current buffer should be ignored
local function should_ignore_buffer()
  local filetype = vim.bo.filetype

  for _, ignored_ft in ipairs(ignored_filetypes) do
    if filetype == ignored_ft then
      return true
    end
  end

  return false
end

-- Switch keyboard layout using keyboardSwitcher
local function switch_keyboard(layout_type)
  if should_ignore_buffer() then
    return
  end

  local layout_id
  if layout_type == 'alternate' then
    layout_id = config.alternate_layout
  elseif layout_type == 'default' then
    layout_id = config.default_layout
  else
    vim.notify("Unknown layout type: " .. layout_type, vim.log.levels.ERROR)
    return
  end

  if not validate_layout(layout_id) then
    vim.notify("Layout '" .. layout_id .. "' is not available on this system", vim.log.levels.ERROR)
    return
  end

  vim.system({'keyboardSwitcher', 'select', layout_id})
end

function M.toggle()
  keyboard_mode = not keyboard_mode

  if keyboard_mode then
	vim.g.KeyboardMode = true
  else
    switch_keyboard('default')
	vim.g.KeyboardMode = false
  end
  vim.api.nvim_exec_autocmds('User', { pattern = 'KeyboardModeChanged' })
end

-- Set keyboard mode to alternate layout
function M.enable()
  if not keyboard_mode then
    M.toggle()
  end
end

-- Set keyboard mode to default layout
function M.disable()
  if keyboard_mode then
    M.toggle()
  end
end

function M.is_enabled()
  return keyboard_mode
end

function M.get_available_layouts()
  return vim.tbl_deep_copy(config.available_layouts)
end

function M.get_config()
  return {
    default_layout = config.default_layout,
    alternate_layout = config.alternate_layout,
    available_layouts = vim.tbl_deep_copy(config.available_layouts)
  }
end

function M.switch_to_layout(layout_name)
  if not layout_name then
    vim.notify('Layout name cannot be nil', vim.log.levels.ERROR)
    return false
  end

  if not validate_layout(layout_name) then
    vim.notify('Layout \"' .. tostring(layout_name) .. '\" is not available', vim.log.levels.ERROR)
    return false
  end

  if should_ignore_buffer() then
    return false
  end

  vim.system({'keyboardSwitcher', 'select', layout_name})
  return true
end

local function setup_autocommands()
  local group = vim.api.nvim_create_augroup('KeyboardMode', { clear = true })

  vim.api.nvim_create_autocmd('User', {
	  group = group,
	  pattern = "KeyboardModeChanged",
	  callback = function()
		  vim.cmd('redrawstatus')
	  end,
  })

  vim.api.nvim_create_autocmd('InsertEnter', {
    group = group,
    callback = function()
      if keyboard_mode then
        switch_keyboard('alternate')
      end
    end,
  })

  vim.api.nvim_create_autocmd('InsertLeave', {
    group = group,
    callback = function()
      if keyboard_mode then
        switch_keyboard('default')
      end
    end,
  })

    -- Search mode switching
  vim.api.nvim_create_autocmd('CmdlineEnter', {
    group = group,
    pattern = '/',
    callback = function()
      if keyboard_mode then
        switch_keyboard('alternate')
      end
    end,
  })

  vim.api.nvim_create_autocmd('CmdlineLeave', {
    group = group,
    pattern = '/',
    callback = function()
      if keyboard_mode then
        switch_keyboard('default')
      end
    end,
  })
end


function M.setup(opts)
  opts = opts or {}

  if vim.fn.has('mac') == 0 then
    vim.notify('KeyboardTools: macOS only', vim.log.levels.ERROR)
    return
  end

  if not check_keyboard_switcher() then
    vim.notify('keyboardSwitcher not found. Please install it with: brew install lutzifer/homebrew-tap/keyboardSwitcher', vim.log.levels.ERROR)
    return
  end

  config.available_layouts = get_available_layouts()
  if #config.available_layouts == 0 then
    vim.notify('KeyboardTools: No keyboard layouts found', vim.log.levels.ERROR)
    return
  end

  config.default_layout = opts.default_layout or 'Canadian'
  config.alternate_layout = opts.alternate_layout or 'Hiragana'
  config.ignored_filetypes = opts.ignored_filetypes or {
    'TelescopePrompt',
    'DressingSelect',
    'DressingInput',
    'noice',
    'notify',
    'prompt',
    'Oil'
  }

  if not validate_layout(config.default_layout) then
    vim.notify('KeyboardTools: Default layout "' .. config.default_layout .. '" not available. Using first available layout: ' .. config.available_layouts[1], vim.log.levels.WARN)
    config.default_layout = config.available_layouts[1]
  end

  if not validate_layout(config.alternate_layout) then
    vim.notify('KeyboardTools: Alternate layout "' .. config.alternate_layout .. '" not available. Using second available layout or default', vim.log.levels.WARN)
    config.alternate_layout = config.available_layouts[2] or config.available_layouts[1]
  end

  vim.g.KeyboardMode = false
  setup_autocommands()
end

return M
