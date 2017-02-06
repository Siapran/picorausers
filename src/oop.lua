-- ################################################################
-- #	OOP BOILERPLATE
-- ################################################################
local timeref = 0
do
	function metatable_search( k, list )
		for e in all(list) do
			local v = e[k]
			if v then return v end
		end
	end

	function metatable_cache( self, k )
		local v = metatable_search(k, self.__parents)
		self[k] = v
		return v
	end

	-- genealogy is 
	function make_genealogy( self, res, has )
		res = res or {}
		has = has or {}
		local parents = self.__parents
		if has[self] then
			return
		end
		if parents and #parents > 0 then
			for parent in all(parents) do
				make_genealogy(parent, res, has)
			end
		end
		add(res, self)
		has[self] = true
		return res
	end

	-- make a class with simple or multiple inheritance
	-- inheritance is implemented as cached first found
	-- do NOT change class methods at runtime, just don't
	function make_class( ... )
		local res = {}
		res.__parents = {...}
		res.__genealogy = make_genealogy(res)
		-- inherited methods are cached to improve runtime performance
		-- caching is done per class, not per object
		if #res.__parents > 0 then
			-- this looks like a closure but actually isn't
			setmetatable(res, {__index = metatable_cache})
		end
		
		res.__index = res

		return res
	end
end

--------------------------------
-- object class
--
local object = make_class()

-- barebone constructor calls class-specific initialisers by traversing the genealogy
-- use factories to create objects conveniently
function object:new( proto )
	res = proto or {}
	setmetatable(res, self)
	if res.init then
		res:init()
	end
	return res
end
