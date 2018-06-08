--[[

Copyright (C) 2016 Ivan Baidakou (basiliscos), http://github.com/basiliscos

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]--

local Gear = {}
Gear.__index = Gear

function Gear.create()
  return setmetatable({
    components = {},
  }, Gear)
end

function Gear:declare(...)
  local args = { ... }
  assert(#args >= 2 and #args <= 4, "incorrect argruments for Gear:declare")
  local name = table.remove(args, 1)
  assert(not self.components[name], "Component " .. name .. " is already declared")
  local constructor
  local dependencies = table.remove(args, 1)

  if (type(dependencies) ~= 'table') then
    constructor = dependencies
    dependencies = {}
  else
    constructor = table.remove(args, 1)
  end

  assert(type(constructor) == 'function', "constructor should be a function")

  local initializer = table.remove(args, 1)
  if (initializer) then
    assert(type(initializer) == 'function', "initializer should be a function")
  end

  self.components[name] = {
    dependencies = dependencies,
    constructor  = constructor,
    initializer  = initializer,
    instance     = nil,
  }
end

function Gear:set(name, instance)
  assert(name)
  local decl = self.components[name]
  if (not decl) then
    decl = { }
    self.components[name] = decl
  end
  decl.instance = instance
end

function Gear:get(name)
  local decl = assert(self.components[name], "No declaration for " .. name)
  if (decl.instance) then return decl.instance end

  -- create instance
  local instance = decl.constructor()
  assert(instance, "Constructor for " .. name .. " should return something")

  -- record the instance to avoid indirect recursion for chicken/egg
  decl.instance = instance

  -- possibly instantiate dependencies
  local dependency_instances = {}
  for _, dependency in ipairs(decl.dependencies) do
    local d = self:get(dependency)
    table.insert(dependency_instances, d)
  end

  -- initialize instance
  if (decl.initializer) then
    decl.initializer(self, instance, table.unpack(dependency_instances))
  end

  return instance
end

Gear.__index = Gear
return Gear
