require("oop")

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
