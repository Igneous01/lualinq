package.path = package.path .. ";lualinqmutable.lua"
local lualinqmutable = require ("lualinqmutable")

expected = { }
expindex = 1

local function setup()
  array = { "ciao", "hello", "au revoir" }
  array2 = { "arrivederci", "goodbye", "bonjour" }
  array3 = { { say="ciao", lang="ita" },  { say="hello", lang="eng" },  }
  array4 = { { say="bonjour", lang="fra", phon="Aeu" }, { say="otka", lang="ale", phon="Outk" }, }
  array5 = { 
    a = { 
      { name="john", surname="snow" },
      { name="elizabeth", surname="taylor" },
    },
    b = {
      { name="melvin", surname="kelvin" },
    },
    c = {
      { name="edward", surname="stark" },
    }
  }
  array6 = { 
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
end
testname = ""
allok = true


function assertneq(v1, v2)
	if (v1 == v2) then
		print("ERROR!! TEST FAILED " .. testname .. " -> " .. tostring(v1) .. " != ".. tostring(v2))
		allok = false
	end
end

function asserteq(v1, v2)
	if (v1 ~= v2) then
		print("ERROR!! TEST FAILED " .. testname .. " -> " .. tostring(v1) .. " == ".. tostring(v2))
		allok = false
	end
end

function assertArray(v)
	asserteq(v, expected[expindex])
	expindex = expindex + 1
end

function assertArrayBegin(tx)
  setup()
	expected = tx
	expindex = 1
end

function assertArrayEnd()
	asserteq(#expected, expindex - 1)
end

function autoexec()
	print("===============================================================")
	setup()
	
	testname = "Test #" ..  1
	assertArrayBegin(array)
	lualinqmutable.from(array)
		:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  2
	assertArrayBegin({4, 5, 9})
		lualinqmutable.from(array)
			:select(function(v) return #v; end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  3
	assertArrayBegin({"ciao", 4, "hello", 5, "au revoir", 9})
	lualinqmutable.from(array)
		  :selectMany(function(v) return { v, #v }; end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  4
	assertArrayBegin({ "HELLO", "AU REVOIR"})
		lualinqmutable.from(array)
			:where(function(v) return #v >= 5; end)
			:select(function(v) return string.upper(v); end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  5
	assertArrayBegin({ "ciao", "au revoir"})
		lualinqmutable.from(array)
			:whereIndex(function (i, v) return ((i % 2)~=0); end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  5
	assertArrayBegin({ "ciao", "hello"})
	lualinqmutable.from(array)
		:take(2)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  6
	assertArrayBegin({ "ciao", "hello", "au revoir", "arrivederci", "goodbye", "bonjour"})
		lualinqmutable.from(array)
			:concat(lualinqmutable.from(array2))
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  7
	assertArrayBegin({ "ciao/arrivederci", "hello/goodbye", "au revoir/bonjour"})
		lualinqmutable.from(array)
			:zip(lualinqmutable.from(array2), function(a,b) return a .. "/" .. b; end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  8
	assertneq(lualinqmutable.from(array):random(), nil)

	testname = "Test #" ..  9
	asserteq(lualinqmutable.from(array):first(), "ciao")

	testname = "Test #" ..  10
	asserteq(lualinqmutable.from(array):last(), "au revoir")

	testname = "Test #" ..  11
	asserteq(lualinqmutable.from(array):any(function(v) return #v > 5; end), true)

	testname = "Test #" ..  12
	asserteq(lualinqmutable.from(array):all(function(v) return #v > 5; end), false)

	testname = "Test #" ..  13
	asserteq(lualinqmutable.from(array):any(function(v) return #v > 15; end), false)

	testname = "Test #" ..  14
	asserteq(lualinqmutable.from(array):contains("hello"), true)

	testname = "Test #" ..  15
	asserteq(lualinqmutable.from(array):contains("qweqhello"), false)

	testname = "Test #" ..  16
	asserteq(lualinqmutable.from(array):sum(function(e) return #e; end), 18)

	testname = "Test #" ..  17
	asserteq(lualinqmutable.from(array):average(function(e) return #e; end), 6)

	testname = "Test #" ..  18
	assertArrayBegin({ "ciao", "hello", "au revoir"})
		lualinqmutable.from({ "ciao", "ciao", "ciao", "hello", "au revoir", "ciao", "hello", "au revoir"})
			:distinct()
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  19
	assertArrayBegin({ "ciao", "yeah", "hello", "au revoir"})
		lualinqmutable.from({ "ciao", "ciao", "yeah"})
			:union(lualinqmutable.from(array))
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  20
	assertArrayBegin({ "yeah"})
		lualinqmutable.from({ "ciao", "yeah", "hello", "au revoir"})
			:except(lualinqmutable.from(array))
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  21
	assertArrayBegin({ "ciao", "hello"})
		lualinqmutable.from({ "ciao", "yeah", "hello", })
			:intersection(array)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  22
	assertArrayBegin({ "ciao" })
		lualinqmutable.from(array3)
			:where("lang", "ita")
			:select("say")
			:foreach(assertArray)
	assertArrayEnd()
	
	testname = "Test #" ..  23
  assertArrayBegin({ "ciao", "hello", "bonjour", "otka" })
    lualinqmutable.from(array3)
      :union(array4)
      :select("say")
      :foreach(assertArray)
  assertArrayEnd()
  
  testname = "Test #" ..  24
  assertArrayBegin({ "bonjour", "fra", "Aeu", "otka", "ale", "Outk" })
  lualinqmutable.from(array4)
      :selectMany(function(v) return { v.say, v.lang, v.phon }; end)
      :foreach(assertArray)
  assertArrayEnd()
  
  testname = "Test #" ..  25
  assertArrayBegin({ "bonjour", "fra", "Aeu", "otka", "ale", "Outk", "ciao", "ita", "hello", "eng" })
  lualinqmutable.from(array4)
      :union(array3)
      :selectMany(function(v) return { v.say, v.lang, v.phon }; end)
      :foreach(assertArray)
  assertArrayEnd()
  
  testname = "Test #" ..  26
  assertArrayBegin({ "john", "elizabeth", "melvin" })
  lualinqmutable.from(array5)
      :where(function(v) return v.key == "a" or v.key == "b" end)
      :selectMany(function(v) 
        return lualinqmutable.from(v.value)
               :select(function(v) return v.name end)
               :toArray()
      end)
      :foreach(assertArray)
  assertArrayEnd()
  
  testname = "Test #" ..  27
  assertArrayBegin({ "john snow", "elizabeth taylor", "edward stark", "melvin kelvin" })
  lualinqmutable.from(array6)
      :selectMany(function(v) 
        return lualinqmutable.from(v.value)
                 :union(v.value.d)
                 :where(function(v) return v.surname ~= nil end)
                 :select(function(v) return v.name .. " " .. v.surname end)
                 :toArray()
      end)
      :foreach(assertArray)
  assertArrayEnd()
	
	if (allok) then
		print("ALL TESTS PASSED!")
	end

end

autoexec()