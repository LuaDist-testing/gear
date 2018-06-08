#!/usr/bin/env lua

require 'Test.More'
local Gear = require "gear"

local g = Gear.create()
g:declare("fuel",
  function() return { class = "fuel" } end
)
g:declare("wheels",
  function() return { class = "wheels" } end
)
g:declare("engine", {"fuel"},
  function() return { class = "engine" } end,
  function(gear, instance, fuel) instance.fuel = fuel end
)
g:set("data/car/year", 2015)
g:declare("car", {"data/car/year", "engine", "wheels"},
  function() return { class = "car" } end,
  function(gear, instance, year, engine, wheels)
    print("year = " .. tostring(year))
    instance.engine = engine
    instance.wheels = wheels
    instance.model  = "MAZ"
    instance.year   = year
  end
)
local car = g:get("car")

ok(car)
ok(car.wheels)
is(car.model, "MAZ")
is(car.year, 2015)
is(car.engine.fuel.class, "fuel")

done_testing()
