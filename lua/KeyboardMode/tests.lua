local M = {}

local mock_vim = {
  fn = {
    has = function(feature)
      if feature == 'mac' then return 1 else return 0 end
    end,
    executable = function(cmd)
      if cmd == 'keyboardSwitcher' then return 1 else return 0 end
    end,
  },
  system = function(cmd)
    if cmd[1] == 'keyboardSwitcher' and cmd[2] == 'list' then
      return {
        wait = function()
          return {
            code = 0,
            stdout = 'Canadian\nHiragana\nU.S.\nFrench\nAvailable Layouts:\n'
          }
        end
      }
    elseif cmd[1] == 'keyboardSwitcher' and cmd[2] == 'select' then
      return {}
    end
  end,
  notify = function(msg, level)
    print('[TEST] ' .. msg)
  end,
  log = { levels = { ERROR = 1, WARN = 2, INFO = 3 } },
  g = {},
  bo = { filetype = 'lua' },
  api = {
    nvim_create_augroup = function() return 1 end,
    nvim_create_autocmd = function() end,
    nvim_exec_autocmds = function() end,
  },
  cmd = function() end,
  tbl_deep_copy = function(t)
    local copy = {}
    for k, v in pairs(t) do
      if type(v) == 'table' then
        copy[k] = vim.tbl_deep_copy(v)
      else
        copy[k] = v
      end
    end
    return copy
  end
}

-- Test suite
local function M.run_tests()
  local original_vim = vim
  vim = mock_vim

  -- Reset the module
  package.loaded['JapaneseTools.init'] = nil
  local keyboard_tools = require('JapaneseTools.init')

  local tests = {
    test_setup_with_defaults,
    test_setup_with_custom_config,
    test_setup_invalid_layout,
    test_toggle_functionality,
    test_is_enabled,
    test_get_available_layouts,
    test_get_config,
    test_switch_to_layout,
    test_layout_validation,
    test_non_mac_system,
    test_missing_keyboard_switcher
  }

  local passed = 0
  local total = #tests

  for i, test in ipairs(tests) do
    local success, error_msg = pcall(test, keyboard_tools)
    if success then
      print('[PASS] ' .. (debug.getinfo(test).name or 'test_' .. i))
      passed = passed + 1
    else
      print('[FAIL] ' .. (debug.getinfo(test).name or 'test_' .. i) .. ': ' .. error_msg)
    end
  end

  print(string.format('\n=== Test Results ==='))
  print(string.format('Passed: %d/%d', passed, total))
  print(string.format('Failed: %d/%d', total - passed, total))

  -- Restore original vim
  vim = original_vim

  return passed == total
end


local function test_setup_with_custom_config(plugin)
  plugin.setup({
    default_layout = 'U.S.',
    alternate_layout = 'French'
  })
  local config = plugin.get_config()

  assert(config.default_layout == 'U.S.', 'Should use custom default layout')
  assert(config.alternate_layout == 'French', 'Should use custom alternate layout')
end

local function test_setup_invalid_layout(plugin)
  -- This should warn and fall back to available layouts
  plugin.setup({
    default_layout = 'NonexistentLayout',
    alternate_layout = 'AnotherNonexistentLayout'
  })
  local config = plugin.get_config()

  -- Should have fallback values
  assert(config.default_layout ~= 'NonexistentLayout', 'Should not use invalid default layout')
  assert(config.alternate_layout ~= 'AnotherNonexistentLayout', 'Should not use invalid alternate layout')
end

local function test_toggle_functionality(plugin)
  plugin.setup()

  -- Should start disabled
  assert(not plugin.is_enabled(), 'Should start disabled')

  -- Toggle to enable
  plugin.toggle()
  assert(plugin.is_enabled(), 'Should be enabled after toggle')

  -- Toggle to disable
  plugin.toggle()
  assert(not plugin.is_enabled(), 'Should be disabled after second toggle')
end


local function test_get_available_layouts(plugin)
  plugin.setup()

  local layouts = plugin.get_available_layouts()
  assert(type(layouts) == 'table', 'Should return table')
  assert(#layouts > 0, 'Should have available layouts')

  -- Check that it's a deep copy (modifying shouldn't affect original)
  local original_count = #layouts
  table.insert(layouts, 'TestLayout')
  local layouts2 = plugin.get_available_layouts()
  assert(#layouts2 == original_count, 'Should return independent copy')
end

local function test_get_config(plugin)
  plugin.setup()

  local config = plugin.get_config()
  assert(type(config) == 'table', 'Should return table')
  assert(config.default_layout, 'Should have default_layout')
  assert(config.alternate_layout, 'Should have alternate_layout')
  assert(config.available_layouts, 'Should have available_layouts')
  assert(type(config.available_layouts) == 'table', 'available_layouts should be table')
end

local function test_switch_to_layout(plugin)
  plugin.setup()

  -- Test valid layout
  local result = plugin.switch_to_layout('Canadian')
  assert(result == true, 'Should return true for valid layout')

  -- Test invalid layout
  local result2 = plugin.switch_to_layout('InvalidLayout')
  assert(result2 == false, 'Should return false for invalid layout')
end

local function test_layout_validation(plugin)
  plugin.setup()

  -- Test with valid layouts
  assert(plugin.switch_to_layout('Canadian'), 'Canadian should be valid')
  assert(plugin.switch_to_layout('Hiragana'), 'Hiragana should be valid')

  -- Test with invalid layouts
  assert(not plugin.switch_to_layout('NonexistentLayout'), 'Should reject invalid layout')
  assert(not plugin.switch_to_layout(''), 'Should reject empty string')
  assert(not plugin.switch_to_layout(nil), 'Should reject nil')
end

local function test_non_mac_system(plugin)
  -- Mock non-Mac system
  vim.fn.has = function(feature) return 0 end

  -- Should handle gracefully and not set up
  plugin.setup()

  -- Restore Mac mock
  vim.fn.has = function(feature)
    if feature == 'mac' then return 1 else return 0 end
  end
end

local function test_missing_keyboard_switcher(plugin)
  -- Mock missing keyboardSwitcher
  vim.fn.executable = function(cmd) return 0 end

  -- Should handle gracefully
  plugin.setup()

  -- Restore keyboardSwitcher mock
  vim.fn.executable = function(cmd)
    if cmd == 'keyboardSwitcher' then return 1 else return 0 end
  end
end

-- Helper assert function
local function assert(condition, message)
  if not condition then
    error(message or 'Assertion failed', 2)
  end
end

return M
