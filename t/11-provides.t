#!/usr/bin/env lua

require 'Test.More'
local Gear = require "gear"

local declarator = function()
  local g = Gear.create()
  g:declare("nuclear-reaction", {
    dependencies = {"Uranium-238"},
    provides     = {"Thorium-234", "Helium-4"},
    constructor  = function() return "process/nuclear-reaction" end,
    initializer  = function() return "element/Thorium-234", "element/Helium-4" end,
  })
  g:declare("Uranium-238", {
    constructor  = function() return "element/Uranium-238" end,
    initializer  = function() end,
  })
  return g
end

subtest("via 1st", function()
  local g = declarator()
  is(g:get("Thorium-234"), "element/Thorium-234")
  is(g:get("Helium-4"), "element/Helium-4")
end)


done_testing()
