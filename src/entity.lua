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
