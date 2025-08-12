#!/usr/bin/env lua

-- Simple test runner for KeyboardTools plugin
-- Run with: lua run_tests.lua

-- Add the lua directory to package path
local script_dir = debug.getinfo(1, "S").source:match("@(.*/)")
package.path = script_dir .. "lua/?.lua;" .. script_dir .. "lua/?/init.lua;" .. package.path

-- Load and run tests
local tests = require('JapaneseTools.tests')

print("Running KeyboardTools Plugin Tests...")
print("=====================================")

local success = tests.run_tests()

if success then
  print("\n✅ All tests passed!")
  os.exit(0)
else
  print("\n❌ Some tests failed!")
  os.exit(1)
end