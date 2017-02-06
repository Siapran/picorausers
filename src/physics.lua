-- ################################################################
-- #	PHYSICS AND HELPERS
-- ################################################################
local rectangle = make_class(object)

function rectangle:init( x0, y0, x1, y1 )
	self.x0 = x0
	self.y0 = y0
	self.x1 = x1
	self.y1 = y1
end

function rectangle:intersects( other )
	return not(other.x0 >= self.x1
		or other.x1 <= self.x0
		or other.y0 >= self.y1
		or other.y1 <= self.y0)
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

local world = make_class(object)

function world:init( )
	self.bounds = rectangle:new(0, 0, 1024, 512)
end

function world:update( )
	self.tree = quadtree:new(0, bounds)
	entity.foreach(function ( ent )
		quadtree:insert(ent)
	end)
end

local collidable = make_class(object)

function collidable:init( x, y, vx, vy, g, colgroup )
	self.x  = x or 0
	self.y  = y or 0
	self.vx = vx or 0
	self.vy = vy or 0
	self.g  = g or 0
	self.colgroup = colgroup or 0
end

function collidable:update( )
	self.x += self.vx
	self.y += self.vy + g
end

function collidable:teleport( x, y )
	self.x = x or 0
	self.y = y or 0
end

local boat = make_class(collidable)

function boat:init( x, y, vx, vy, g, colgroup, bounds )
	collidable.init(self, x, y, vx, vy, g, colgroup)
	self.bounds = bounds
end

function boat:get_bounds( )
	return self.bounds
end

local steerable = make_class(collidable)

function steerable:init( x, y, vx, vy, g  )
	-- body
end
