do
	local function metatable_search( k, list )
		for e in all(list) do
			local v = e[k]
			if v then return v end
		end
	end

	local function metatable_cache( self, k )
		local v = metatable_search(k, self.__parents)
		self[k] = v
		return v
	end

	-- genealogy is 
	local function make_genealogy( self, res, has )
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
		res.__instanceof_cache = {}
		-- inherited methods are cached to improve runtime performance
		-- caching is done per class, not per object
		if #res.__parents > 0 then
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


-- use factories to create objects conveniently
function object:new( ... )
	local res = {}
	setmetatable(res, self)
	if res.init then
		res:init(...)
	end
	return res
end

function object:instanceof( class )
	local cache = self.__instanceof_cache
	if cache[class] ~= nil then
		return cache[class]
	else
		for v in all(self.__genealogy) do
			if class == v then
				cache[class] = true
				return true
			end
		end
		cache[class] = false
		return false
	end
end

-- general purpose utils

-- asssign unique ids to tables
do
    local cache = setmetatable({}, {__mode = "k"})
    local id = 0
    function identifier( table )
        if cache[table] then
            return cache[table]
        else
            cache[table] = id
            id = id + 1
            return id
        end
    end
end
