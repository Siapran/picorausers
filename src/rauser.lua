require("oop")

local rauser = make_class(steerable)

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

function rauser:init(  )
	
end

function rauser:update( )
	
end