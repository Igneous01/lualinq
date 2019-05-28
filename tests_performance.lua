package.path = package.path .. ";lualinqmutable.lua"
package.path = package.path .. ";lualinq.lua"
local lualinqmutable = require ("lualinqmutable")
local lualinq = require ("lualinq")

local array = {}
local dictionary = { 
  a = { 
    { name="john", surname="snow" },
    { name="elizabeth", surname="taylor" },
  },
  b = {
    { name="melvin", surname="kelvin" },
  },
  c = {
    d = {
      { name="edward", surname="stark" },
    }  
  }
}

local charset = {}  do -- [0-9a-zA-Z]
    for c = 48, 57  do table.insert(charset, string.char(c)) end
    for c = 65, 90  do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end

local function randomString(length)
    if not length or length <= 0 then return '' end
    math.randomseed(os.clock()^5)
    return randomString(length - 1) .. charset[math.random(1, #charset)]
end

local _insert = table.insert
local _random = math.random
math.randomseed(os.time())

for n = 1, 100000 do
  _insert(array, _random(100))
  if n < 25000 then
    _insert(dictionary.a, { name = randomString(5), surname = randomString(7)})
  elseif n < 45000 then
    _insert(dictionary.b, { name = randomString(7), surname = randomString(9)})
  else
    _insert(dictionary.c.d, { name = randomString(4), surname = randomString(6)})
  end
end

local function profileCall(name, expression)
  local time = os.clock()
  expression()
  time = os.clock() - time
  print((name .. " results: %.3f seconds"):format(time))
end

profileCall("lualinq.from:where:distinct:toArray", function()
  local r = lualinq.from(array)
               :where(function(n) return n >= 50 end)
               :distinct()
               :toArray()
end)

profileCall("lualinqmutable.from:where:distinct:toArray", function()
  local r = lualinqmutable.from(array)
               :where(function(n) return n >= 50 end)
               :distinct()
               :toArray()
end)

profileCall("lualinq.from:selectMany(from:concat:where:select:toArray):toArray", function()
  local r = lualinq.from(dictionary)
                :selectMany(function(v) 
                  return lualinq.from(v.value)
                           :concat(lualinq.from(v.value.d))
                           :where(function(v) return v.surname ~= nil end)
                           :select(function(v) return v.name .. " " .. v.surname end)
                           :toArray()
                end)
                :toArray()
end)

profileCall("lualinqmutable.from:selectMany(from:concat:where:select:toArray):toArray", function()
  local r = lualinqmutable.from(dictionary)
                :selectMany(function(v) 
                  return lualinqmutable.from(v.value)
                           :concat(lualinqmutable.from(v.value.d))
                           :where(function(v) return v.surname ~= nil end)
                           :select(function(v) return v.name .. " " .. v.surname end)
                           :toArray()
                end)
                :toArray()
end)


