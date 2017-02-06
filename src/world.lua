require("oop")

world = make_class(object)

function world:init( )
	self.bounds = rectangle:new(0, 0, 1024, 512)
end

function world:update( )
	self.tree = quadtree:new(0, bounds)
	entity.foreach(function ( ent )
		quadtree:insert(ent)
	end)
end
