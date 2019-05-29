package.path = package.path .. ";lualinq.lua"
local lualinq = require ("lualinq")

expected = { }
expindex = 1
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
	expected = tx
	expindex = 1
end

function assertArrayEnd()
	asserteq(#expected, expindex - 1)
end

function autoexec()
	print("===============================================================")

	testname = "Test #" ..  1
	assertArrayBegin(array)
	lualinq.from(array)
		:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  2
	assertArrayBegin({4, 5, 9})
		lualinq.from(array)
			:select(function(v) return #v; end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  3
	assertArrayBegin({"ciao", 4, "hello", 5, "au revoir", 9})
	lualinq.from(array)
		  :selectMany(function(v) return { v, #v }; end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  4
	assertArrayBegin({ "HELLO", "AU REVOIR"})
		lualinq.from(array)
			:where(function(v) return #v >= 5; end)
			:select(function(v) return string.upper(v); end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  5
	assertArrayBegin({ "ciao", "au revoir"})
		lualinq.from(array)
			:whereIndex(function (i, v) return ((i % 2)~=0); end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  5
	assertArrayBegin({ "ciao", "hello"})
	lualinq.from(array)
		:take(2)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  6
	assertArrayBegin({ "ciao", "hello", "au revoir", "arrivederci", "goodbye", "bonjour"})
		lualinq.from(array)
			:concat(lualinq.from(array2))
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  7
	assertArrayBegin({ "ciao/arrivederci", "hello/goodbye", "au revoir/bonjour"})
		lualinq.from(array)
			:zip(lualinq.from(array2), function(a,b) return a .. "/" .. b; end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  8
	assertneq(lualinq.from(array):random(), nil)

	testname = "Test #" ..  9
	asserteq(lualinq.from(array):first(), "ciao")

	testname = "Test #" ..  10
	asserteq(lualinq.from(array):last(), "au revoir")

	testname = "Test #" ..  11
	asserteq(lualinq.from(array):any(function(v) return #v > 5; end), true)

	testname = "Test #" ..  12
	asserteq(lualinq.from(array):all(function(v) return #v > 5; end), false)

	testname = "Test #" ..  13
	asserteq(lualinq.from(array):any(function(v) return #v > 15; end), false)

	testname = "Test #" ..  14
	asserteq(lualinq.from(array):contains("hello"), true)
	
	testname = "Test #" ..  14
  asserteq(lualinq.from(array):contains("hello", function(a, item) return a == item end), true)

	testname = "Test #" ..  15
	asserteq(lualinq.from(array):contains("qweqhello"), false)

	testname = "Test #" ..  16
	asserteq(lualinq.from(array):sum(function(e) return #e; end), 18)

	testname = "Test #" ..  17
	asserteq(lualinq.from(array):average(function(e) return #e; end), 6)

	testname = "Test #" ..  18
	assertArrayBegin({ "ciao", "hello", "au revoir"})
		lualinq.from({ "ciao", "ciao", "ciao", "hello", "au revoir", "ciao", "hello", "au revoir"})
			:distinct()
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  19
	assertArrayBegin({ "ciao", "yeah", "hello", "au revoir"})
		lualinq.from({ "ciao", "ciao", "yeah"})
			:union(lualinq.from(array))
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  20
	assertArrayBegin({ "yeah"})
		lualinq.from({ "ciao", "yeah", "hello", "au revoir"})
			:except(lualinq.from(array))
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  21
	assertArrayBegin({ "ciao", "hello"})
		lualinq.from({ "ciao", "yeah", "hello", })
			:intersection(array)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  22
	assertArrayBegin({ "ciao" })
		lualinq.from(array3)
			:where("lang", "ita")
			:select("say")
			:foreach(assertArray)
	assertArrayEnd()
	
	testname = "Test #" ..  23
  assertArrayBegin({ "ciao", "hello", "bonjour", "otka" })
    lualinq.from(array3)
      :union(array4)
      :select("say")
      :foreach(assertArray)
  assertArrayEnd()
  
  testname = "Test #" ..  24
  assertArrayBegin({ "bonjour", "fra", "Aeu", "otka", "ale", "Outk" })
  lualinq.from(array4)
      :selectMany(function(v) return { v.say, v.lang, v.phon }; end)
      :foreach(assertArray)
  assertArrayEnd()
  
  testname = "Test #" ..  25
  assertArrayBegin({ "bonjour", "fra", "Aeu", "otka", "ale", "Outk", "ciao", "ita", "hello", "eng" })
  lualinq.from(array4)
      :union(array3)
      :selectMany(function(v) return { v.say, v.lang, v.phon }; end)
      :foreach(assertArray)
  assertArrayEnd()
  
  testname = "Test #" ..  26
  assertArrayBegin({ "john", "elizabeth", "melvin" })
  lualinq.from(array5)
      :where(function(v) return v.key == "a" or v.key == "b" end)
      :selectMany(function(v) 
        return lualinq.from(v.value)
               :select(function(v) return v.name end)
               :toArray()
      end)
      :foreach(assertArray)
  assertArrayEnd()
  
  testname = "Test #" ..  27
  assertArrayBegin({ "john snow", "elizabeth taylor", "edward stark", "melvin kelvin" })
  lualinq.from(array6)
      :selectMany(function(v) 
        return lualinq.from(v.value)
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