local M = {}

local japanese_mode = false

-- Check if keyboardSwitcher is installed
local function check_keyboard_switcher()
  -- Use vim.fn.executable instead of which
  return vim.fn.executable('keyboardSwitcher') == 1
end

-- Check if current buffer should be ignored
local function should_ignore_buffer()
  local filetype = vim.bo.filetype
  local ignored_filetypes = {
    'TelescopePrompt',
    'DressingSelect',
    'DressingInput',
    'noice',
    'notify',
    'prompt',
    'Oil'
  }

  for _, ignored_ft in ipairs(ignored_filetypes) do
    if filetype == ignored_ft then
      return true
    end
  end

  return false
end

-- Switch keyboard layout using keyboardSwitcher
local function switch_keyboard(layout_name)
  if should_ignore_buffer() then
    return
  end

  local layout_map = {
    ['Japanese'] = 'Hiragana',
    ['Canadian English'] = 'Canadian'
  }

  local layout_id = layout_map[layout_name]
  if not layout_id then
    vim.notify("Unknown layout: " .. layout_name, vim.log.levels.ERROR)
    return
  end

  vim.system({'keyboardSwitcher', 'select', layout_id})
end

function M.toggle()
  japanese_mode = not japanese_mode

  if japanese_mode then
    vim.notify("Japanese mode: ON", vim.log.levels.INFO)
  else
    vim.notify("Japanese mode: OFF", vim.log.levels.INFO)
    switch_keyboard('Canadian English')
  end
end

local function setup_autocommands()
  local group = vim.api.nvim_create_augroup('JapaneseMode', { clear = true })

  vim.api.nvim_create_autocmd('InsertEnter', {
    group = group,
    callback = function()
      if japanese_mode then
        switch_keyboard('Japanese')
      end
    end,
  })

  vim.api.nvim_create_autocmd('InsertLeave', {
    group = group,
    callback = function()
      if japanese_mode then
        switch_keyboard('Canadian English')
      end
    end,
  })
end

function M.setup()
  if vim.fn.has('mac') == 0 then
    vim.notify('Japanese mode: macOS only', vim.log.levels.ERROR)
    return
  end

  if not check_keyboard_switcher() then
    vim.notify('keyboardSwitcher not found. Please install it with: brew install lutzifer/homebrew-tap/keyboardSwitcher', vim.log.levels.ERROR)
    return
  end

  setup_autocommands()
end

return M
