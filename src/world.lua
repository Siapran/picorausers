require("oop")
require("quadtree")
require("physics")
require("graphics")

local world = make_class(object)

do
	function world:init( )
		self.bounds = rectangle:new(0, 0, 1024, 512)
	end

	function world:draw( )
		
	end
	
end