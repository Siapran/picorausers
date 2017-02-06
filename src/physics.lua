require("oop")

-- ################################################################
-- #	PHYSICS AND HELPERS
-- ################################################################
rectangle = make_class(object)

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

collidable = make_class(object)

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

boat = make_class(collidable)

function boat:init( x, y, vx, vy, g, colgroup, bounds )
	collidable.init(self, x, y, vx, vy, g, colgroup)
	self.bounds = bounds
end

function boat:get_bounds( )
	return self.bounds
end

steerable = make_class(collidable)

function steerable:init( x, y, vx, vy, g  )
	-- body
end
