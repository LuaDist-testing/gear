#!/usr/bin/env lua

require 'Test.More'
local Gear = require "gear"

local g = Gear.create()
g:declare("fuel", {
  constructor = function() return { class = "fuel" } end
})
g:declare("wheels", {
  constructor = function() return { class = "wheels" } end
})
g:declare("engine",{
  dependencies = {"fuel"},
  constructor  = function() return { class = "engine" } end,
  initializer  = function(gear, instance, fuel) instance.fuel = fuel end,
})
g:set("data/car/year", 2015)
g:declare("car",{
  dependencies = {"data/car/year", "engine", "wheels"},
  constructor  = function() return { class = "car" } end,
  initializer  = function(gear, instance, year, engine, wheels)
    print("year = " .. tostring(year))
    instance.engine = engine
    instance.wheels = wheels
    instance.model  = "MAZ"
    instance.year   = year
  end
})

local car = g:get("car")

ok(car)
ok(car.wheels)
is(car.model, "MAZ")
is(car.year, 2015)
is(car.engine.fuel.class, "fuel")

done_testing()
