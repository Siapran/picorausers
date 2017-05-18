require("oop")
require("shapes")

local quadtree = make_class(object)

local quadtree_max_objects = 8

function quadtree:init( x, y, w, h )
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.children = nil
	self.objects = {}
end

function quadtree:subdivide( )
	local x, y, h, h = self.x, self.y, self.w / 2, self.h / 2
	self.children = {
		quadtree(x    , y    , w, h),
		quadtree(x + w, y    , w, h),
		quadtree(x    , y + h, w, h),
		quadtree(x + w, y + h, w, h)
	}
end

function quadtree:insert( object, oncollide )
	if self.children then
		for child in all(self.children) do
			child:subdivide()
		end
	else
		if #self.objects > 0 then
			oncollide(object, self.objects)
		end
		add(self.objects, object)
	end
end