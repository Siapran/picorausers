require("oop")
require("graphics")

rauser = make_class(steerable)

rauser.types = {
	gun = {"original", "beam", "spread", "missiles", "cannon"},
	body = {"original", "armor", "melee", "nuke", "bomb"},
	engine = {"original", "superboost", "gungine", "underwater", "hover"}
}

rauser.current_type = {
	gun    = 1,
	body   = 1,
	engine = 1
}

rauser.coordinates = {
	x = 64,
	y = 64
}

rauser.angle = 0

rauser.speed = 0

function rauser_update( ... )
	
end

function rauser_draw( ... )
	
end