require("oop")

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
