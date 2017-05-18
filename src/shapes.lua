require("oop")
require("vector2")

local rectangle = make_class(object)

function rectangle:init( x, y, w, h )
	self.x = x
	self.y = y
	self.w = w
	self.h = h
end

function rectangle:intersects( other )
	local ax2, ay2, bx2, by2 =
		self.x + self.w, self.y + self.h,
		other.x + other.w, other.y + other.h
		return self.x < bx2
			and ax2 > other.x
			and self.y < by2
			and ay2 > other.y
end


function draw_rect( x, y, w, h, col )
	rectfill(x, y, x + w, y + h, col)
end
