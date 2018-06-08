#!/usr/bin/env lua

require 'Test.More'
local Gear = require "gear"

local declarator = function()
  local g = Gear.create()
  g:declare("chicken", {
    dependencies = {"egg"},
    constructor  = function() return { class = "chicken" } end,
    initializer  = function(g, instance, egg) instance.egg = egg end,
  })
  g:declare("egg", {
    dependencies = {"chicken"},
    constructor  = function() return { class = "egg" } end,
    initializer  = function(g, instance, chicken) instance.chicken = chicken end,
  })
  return g
end

subtest("via chicken", function()
  local g = declarator()
  local chicken = g:get("chicken")
  ok(chicken)
  is(chicken.class, "chicken")
  ok(chicken.egg)
  is(chicken.egg.class, "egg")
  is(chicken.egg.chicken, chicken)
end)
subtest("via egg", function()
  local g = declarator()
  local egg = g:get("egg")
  ok(egg)
  is(egg.class, "egg")
  ok(egg.chicken)
  is(egg.chicken.class, "chicken")
  is(egg.chicken.egg, egg)
end)

done_testing()
