require("oop")

quadtree = make_class(object)

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