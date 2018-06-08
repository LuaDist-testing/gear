#!/usr/bin/env lua

require 'Test.More'
require 'Coat'

local meta = require 'Coat.Meta.Class'

class 'Egg'
has.name = { is = 'ro' }
has.chicken = { is = 'ro', isa = 'Chicken' }

class 'Chicken'
has.egg = { is = 'ro', isa = 'Egg' }


local Gear = require "gear"
local gear = Gear.create()

local resolver = function(component_name)
  -- drop "my/" prefix
  local my_class_name = string.sub(component_name, 4)
  local my_class = _ENV[my_class_name]
  local dependencies = {}
  for name, attr in meta.attributes(my_class) do
    local property_class_name = attr.isa
    local property_class = _ENV[property_class_name]
    if (property_class) then
      -- add "my/" prefix
      table.insert(dependencies, "my/" .. property_class_name)
    end
  end
  return dependencies
end

gear:declare("my/Chicken", {
  resolver    = resolver,
  constructor = function() return Chicken { } end,
  initializer = function(gear, instance, egg) instance.egg = egg end,
})
gear:declare("my/Egg", {
  resolver    = resolver,
  constructor = function() return Egg { name = "smallie" } end,
  initializer = function(gear, instance, chicken) instance.chicken = chicken end,
})

local chicken = gear:get("my/Chicken")
ok(chicken)
is(chicken.egg.name, "smallie")

done_testing()
