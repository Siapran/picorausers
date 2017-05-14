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

local vector2 = make_class(object)

function vector2:init(x, y)
	self.x = x
	self.y = y
end

function vector2:__unm( )
	return vector2:new(-self.x, -self.y)
end

function vector2:__add( other )
	if type(other) == "table" then
		return vector2:new(self.x + other.x, self.y + other.y)
	else
		return vector2:new(self + other.x, self + other.y)
	end
end

function vector2:__sub( other )
	return self + (-other)
end

function vector2:__mul( other )
	return vector2:new(self.x * other, self.y * other)
end

function vector2:__div( other )
	return vector2:new(self.x / other, self.y / other)
end

function vector2:__mod( other )
	return vector2:new(self.x % other, self.y % other)
end

function vector2:__eq( other )
	return self.x == other.x and self.y == other.y
end

local quadtree = make_class(object)

quadtree.__max_objects = 8
quadtree.__max_levels  = 8

function quadtree:init( level, bounds )
	self.level = level or 0
	self.objects = {}
	self.nodes = {}
	self.bounds = bounds
end

function quadtree:split( )
	local sub_rectangles = self.bounds:split()
	for i=1,4 do
		self.nodes[i] = quadtree:new(self.level + 1, sub_rectangles[i])
	end
end

function quadtree:getindex( bounds )
	local index = nil
	local mx, my = self.bounds:midpoints()
	local top = self
end

--------------------------------
-- entities: the backbone of the game engine
--
local entity = make_class(object)

-- entities are registered in a static table
entity.__entities = {}

function entity.foreach( func )
	for _,ent in pairs(entity.__entities) do
		func(ent)
	end
end

function entity:init( )
	entity.__entities[self] = self
end

function entity:destroy( )
	entity.__entities[self] = nil
end

-- entities run a thread that yields to the update loop
function entity:run( func )
	self.thread = cocreate(func)
end

function entity:update( )
	local result = self.thread and coresume(self.thread, self)
	if not result then
		self.thread = nil
	end
end
-- ################################################################
-- #	GRAPHICS AND CACHING
-- ################################################################

-- forward declaration
local rauser

local screen_address = 0x6000
local palette = {0, 1, 2, 4, 9, 15, 7}

-- copies a portion of memory to another following the gxf memory layout
-- does not work with odd widths
function copy_gfx( source, dest, w, h )
	w = w / 2
	h = h - 1
	for i=0,h do
		memcpy(dest + i * 64, source + i * 64, w)
	end
end

function copy_screen( x0, y0, x1, y1, w, h )
	local source = 0x6000 + y0 * 64 + x0 / 2
	local dest = 0x6000 + y1 * 64 + x1 / 2
	w = w / 2
	h = h - 1
	for i=0,h do
		memcpy(dest + i * 64, source + i * 64, w)
	end
end

-- rotates a sprite around its center
-- source: sprite number
-- angle: rotation angle (0..1)
-- size: number of 8x8 tiles in width and height
function rotate( source, angle, size )
	angle = flr(angle * 16 + 0.5) / 16
	local ca, sa = cos(angle), sin(angle)
	size = size * 8
	local half = (size) / 2
	local xo, yo = source % 16 * 8, flr(source / 16) * 8

	-- raster sampling rotation
	-- not the fastest, but gives better results than shearing
	for x = 0.5, half do
		for y = 0.5, half do
			xp =  x * ca + y * sa + half
			yp = -x * sa + y * ca + half

			-- replicating the quadrant saves about 10% cpu
			if xp == xp % size and yp == yp % size then
				pset( x + half,  y + half, pget(       xp + xo,        yp + yo))
				pset( y + half, -x + half, pget(       yp + xo, size - xp + yo))
				pset(-x + half, -y + half, pget(size - xp + xo, size - yp + yo))
				pset(-y + half,  x + half, pget(size - yp + xo,        xp + yo))
			end
		end
	end
end

rotatable_sprites = {
	rauser = {
		adress = 0x2000,
		layout = "line",
		size = 2,
		render_func = function ( adress, angle )
			rectfill(0, 0, 31, 15, 0)
			-- ajust indexes
			local nums = {}

			for k,v in pairs(rauser.current_type) do
				nums[k] = v - 1
			end

			-- wings
			sspr(
				nums.gun * 16, 64,
				16, 8,
				16 + 8.5 - 8 * cos(angle), 4,
				16 * cos(angle), 8
			)

			-- body + engine
			spr(nums.body + 144,16 + 4, 3, 1, 1)
			spr(nums.engine + 149,16 + 4, 11, 1, 1)

			-- rotate the whole thing
			rotate(2, angle, 2)

			copy_gfx(screen_address, adress, 16, 16)
		end
	},
	fighter = {
		adress = 0x2800,
		layout = "line",
		size = 2,
		render_func = function ( adress, angle )
			rectfill(0, 0, 31, 15, 0)
			-- wings
			sspr(
				16, 88,
				16, 8,
				16 + 8.5 - 8 * cos(angle), 4,
				16 * cos(angle), 8
			)

			-- body + engine
			spr(177,16 + 4, 4, 1, 1)


			-- rotate the whole thing
			rotate(2, angle, 2)

			copy_gfx(screen_address, adress, 16, 16)
		end
	},
	ace = {
		adress = 0x4400,
		layout = "square",
		size = 3,
		render_func = function ( adress, angle )
			rectfill(0, 0, 47, 23, 0)
			-- wings
			sspr(
				8, 80,
				24, 8,
				24 + 12.5 - 12 * cos(angle), 6,
				24 * cos(angle), 8
			)

			-- body + engine
			spr(160,24 + 8, 0, 1, 3)


			-- rotate the whole thing
			rotate(3, angle, 3)

			copy_gfx(screen_address, adress, 24, 24)
		end
	},
	missile = {
		adress = 0x4430,
		layout = "square",
		size = 1,
		render_func = function ( adress, angle )
			generic_rotate_prerender(adress, angle, 195)
		end
	},
	jet = {
		adress = 0x4C30,
		layout = "square",
		size = 1,
		render_func = function ( adress, angle )
			generic_rotate_prerender(adress, angle, 194)
		end
	},
	cannon = {
		adress = 0x5430,
		layout = "square",
		size = 1,
		render_func = function ( adress, angle )
			generic_rotate_prerender(adress, angle, 194)
		end
	},
	flak = {
		adress = 0x5C00,
		layout = "line",
		size = 1,
		render_func = function ( adress, angle )
			generic_rotate_prerender(adress, angle, 193)
		end
	}
}

function generic_rotate_prerender( adress, angle, sprite_number )
	rectfill(0, 0, 15, 7, 0)
	spr(sprite_number, 8, 0, 1, 1)
	rotate(1, angle, 1)
	copy_gfx(screen_address, adress, 8, 8)
end

do
	local value
	function give( item )
		value = item
		yield()
	end
	function take( supplier, ... )
		local res = coresume(supplier, ...)
		return res and value or nil
	end
end

function make_adress_supplier( layout, adress, step )
	if layout == "square" then
		return cocreate(function ( )
			for i=0,3 do
				for j=0,3 do
					give(adress
						+ i * 64 * step
						+ j * step / 2)
				end
			end
		end)
	end
	if layout == "line" then
		return cocreate(function ( )
			local items = 64 / (step / 2)
			local lines = 16 / items
			for i=0,lines - 1 do
				for j=0,items - 1 do
					give(adress
						+ i * 64 * step
						+ j * step / 2)
				end
			end
		end)
	end
end

function hex(value)
	local b, k, res, i, d = 16, "0123456789abcdef", "", 0
	while value > 0 do
		i = i + 1
		value, d = flr(value / b), (value % b) + 1
		res = sub(k, d, d) .. res
	end
	return "0x" .. res
end

do
	local name = ""
	local loading_message = ""
	local loading_progress = 0
	local loading_total_ops = 16 * 7

	function prerender( sprite )
		local adress_supplier =
			make_adress_supplier(
				sprite.layout,
				sprite.adress,
				sprite.size * 8)
		sprite.prerenders = {}
		for angle=0,15/16,1/16 do
			local adress = take(adress_supplier)
			-- printh(name .. " - " .. hex(adress) .. " - " .. angle)
			sprite.render_func(adress, angle)
			if sprite.size <= 1 then
				sprite.prerenders[angle] = adress
			else
				sprite.prerenders[angle] = {}
				local n = 1
				for i=0,sprite.size-1 do
					for j=0,sprite.size-1 do
						sprite.prerenders[angle][n] =
							adress + i * 512 + j * 4
						n += 1
					end
				end
			end
			loading_progress = loading_progress + 1
			yield()
		end
	end

	function prerender_all( )
		for key,sprite in pairs(rotatable_sprites) do
			name = key
			loading_message = "prerendering: " .. name
			prerender(sprite)
		end
	end

	local loading_thread = cocreate(prerender_all)
	local cpu = 0
	local done = false

	function update_loading( )
		local res
		cpu = 0
		while cpu < 0.8 do
			res = coresume(loading_thread)
			if not res then
				-- copy_gfx(0x2000, 0x6000, 128, 64)
				-- copy_gfx(0x4400, 0x7000, 128, 64)
				done = true
				change_state("rauser_test")
				return
			end
			cpu = cpu + stat(1)
		end
	end

	function print_centered( str, x, y, col, shadow )
		local offset = #str * 2
		if shadow then
			print(str, x - offset + 1, y, shadow)
			print(str, x - offset, y + 1, shadow)
			print(str, x - offset + 1, y + 1, shadow)
		end
		print(str, x - offset, y, col)
	end

	function draw_loading( )
		local percent = flr(loading_progress / loading_total_ops * 100)
		rectfill(0, 0, 127, 127, palette[5])
		-- print_centered(percent .. "%", 64, 80, palette[7], palette[3])
		draw_rect(13, 54, 103, 17, palette[3])
		draw_rect(14, 55, 103, 17, palette[7])
		draw_rect(14, 55, 102, 16, palette[4])
		draw_rect(14, 55, percent + 1, 15, palette[7])
		draw_rect(15, 56, percent + 1, 15, palette[3])
		draw_rect(15, 56, percent, 14, palette[6])
		print_centered(loading_message, 64, 60, palette[7], palette[3])
	end
end

do
	local map = {}
	local newest = {}
	local oldest = {}
	newest.next = oldest
	oldest.prev = newest

	local function set_newest( tuple )
		tuple.next = newest.next
		tuple.next.prev = tuple
		newest.next = tuple
		tuple.prev = newest
	end

	local function cut_tuple( tuple )
		tuple.prev.next = tuple.next
		tuple.next.prev = tuple.prev
	end

	for i=0,127 do
		set_newest({ owner = nil, value = 128 + i,
			adress = 0x1000 + flr(i / 16) * 512 + (i % 16) * 4 })
	end

	-- this function maps prerender adresses to an api accessible sprite cache
	local function get_sprite_num( adress )
		local tuple = map[adress]
		if not tuple then
			tuple = oldest.prev
			if tuple.owner then
				map[tuple.owner] = nil
			end
			copy_gfx(adress, tuple.adress, 8, 8)
			tuple.owner = adress
			map[adress] = tuple
		end
		cut_tuple(tuple)
		set_newest(tuple)
		return tuple.value
	end

	function draw_cached( sprite, x, y, angle )
		if sprite.size <= 1 then
			spr(get_sprite_num(sprite.prerenders[angle]), x, y)
		else
			local n = 1
			printh("reached")
			for i=0,sprite.size-1 do
				for j=0,sprite.size-1 do
					spr(get_sprite_num(sprite.prerenders[angle][n]), x + j * 8, y + i * 8)
					n += 1
				end
			end
		end
	end
end

do
	rauser = make_class(steerable)

	rauser.types = {
		gun = {"original", "beam", "spread", "missiles", "cannon"},
		body = {"original", "armor", "melee", "nuke", "bomb"},
		engine = {"original", "superboost", "gungine", "underwater", "hover"}
	}

	rauser.current_type = {
		gun    = 1,
		body   = 1,
		engine = 1
	}

	rauser.position = vector2:new(64, 64)
	rauser.velocity = vector2:new(0, 0)

	rauser.angle = 0
	rauser.thrust = 0
	rauser.gravity = 0

	local sprite = rotatable_sprites.rauser

	function rauser:draw( ... )
		local x = rauser.position.x
		local y = rauser.position.y

		-- camera(x - 64, y - 64)
		-- for i=0,128,16 do
		-- 	for j=0,128,16 do
		-- 		pset(x - 64 + i - x % 16, y - 64 + j - y % 16, 7)
		-- 	end
		-- end
		draw_cached(sprite, x - 8, y - 8, flr(rauser.angle * 16) / 16)
	end

	function rauser:update( ... )
		rauser.gravity += 0.15
		if btn (0) then
			rauser.angle = (rauser.angle + 1/48) % 1
		end
		if btn (1) then
			rauser.angle = (rauser.angle - 1/48) % 1
		end
		if btn (2) then
			rauser.thrust += 2
			rauser.gravity *= 0.01
		end
		rauser.thrust *= 0.25
		rauser.gravity *= 0.7
		rauser.velocity += vector2:new(rauser.thrust * cos(rauser.angle + 1/4), rauser.thrust * sin(rauser.angle + 1/4))
		rauser.velocity.y += rauser.gravity
		rauser.velocity *= 0.99

		rauser.position += rauser.velocity
		rauser.position %= 128

	end

	function rauser_update( ... )
		rauser:update()
	end

	function rauser_draw( ... )
		cls()
		rauser:draw()
	end
end

local rectangle = make_class(object)

function rectangle:init( x, y, half_width, half_height )
	self.x = x
	self.y = y
	self.hw = half_width
	self.hh = half_height
end

function rectangle:intersects( other )
	return 
end

function rectangle:contains( x, y )
	return self.x0 <= x and x < self.x1 and
		self.y0 <= y and y < self.y1
end

function rectangle:split( )
	local mx, my = self:midpoints()
	return {
		rectangle:new(self.x0, self.y0, mx, my),
		rectangle:new(mx, self.y0, self.x1, my),
		rectangle:new(mx, my, self.x1, self.y1),
		rectangle:new(self.x0, my, mx, self.y1)
	}
end

function rectangle:midpoints( )
	return
		(self.x0 + self.x1) / 2,
		(self.y0 + self.y1) / 2
end

function draw_rect( x, y, w, h, col )
	rectfill(x, y, x + w, y + h, col)
end

local world = make_class(object)

do
	function world:init( )
		self.bounds = rectangle:new(0, 0, 1024, 512)
	end

	function world:draw( )
		
	end
	
end

timeref = 0

do
	local update_functions = {
		loading = update_loading,
		rauser_test = rauser_update,
	}

	local draw_functions = {
		loading = draw_loading,
		rauser_test = rauser_draw,
	}

	function change_state( state )
		printh("Changed state to " .. state)
		gamestate = state
		_update = update_functions[gamestate]
		_draw = draw_functions[gamestate]
	end

	function _init( )
		change_state("loading")
	end
end
