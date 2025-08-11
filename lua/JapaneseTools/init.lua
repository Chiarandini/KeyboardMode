local M = {}

local japanese_mode = false
local config = {
  english_layout = 'Canadian',
  japanese_layout = 'Hiragana'
}

-- Check if keyboardSwitcher is installed
local function check_keyboard_switcher()
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
local function switch_keyboard(layout_type)
  if should_ignore_buffer() then
    return
  end

  local layout_id
  if layout_type == 'Japanese' then
    layout_id = config.japanese_layout
  elseif layout_type == 'English' then
    layout_id = config.english_layout
  else
    vim.notify("Unknown layout type: " .. layout_type, vim.log.levels.ERROR)
    return
  end

  vim.system({'keyboardSwitcher', 'select', layout_id})
end

function M.toggle()
  japanese_mode = not japanese_mode

  if japanese_mode then
	vim.g.JapaneseMode = true
  else
    switch_keyboard('English')
	vim.g.JapaneseMode = false
  end
  vim.api.nvim_exec_autocmds('User', { pattern = 'JapaneseModeChanged' })
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
        switch_keyboard('English')
      end
    end,
  })
end


function M.setup(opts)
  opts = opts or {}

  -- Merge user config with defaults
  config.english_layout = opts.english_layout or 'Canadian'
  config.japanese_layout = opts.japanese_layout or 'Hiragana'

  if vim.fn.has('mac') == 0 then
    vim.notify('Japanese mode: macOS only', vim.log.levels.ERROR)
    return
  end

  if not check_keyboard_switcher() then
    vim.notify('keyboardSwitcher not found. Please install it with: brew install lutzifer/homebrew-tap/keyboardSwitcher', vim.log.levels.ERROR)
    return
  end
  vim.g.JapaneseMode = false
  setup_autocommands()
end

return M
