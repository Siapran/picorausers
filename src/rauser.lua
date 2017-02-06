require("oop")

rauser = make_class(object)

rauser.types = {
	gun = {"original", "beam", "spread", "missiles", "cannon"},
	body = {"original", "armor", "melee", "nuke", "bomb"},
	engine = {"original", "superboost", "gungine", "underwater", "hover"}
}

rauser.current_type = {
	gun	= 1,
	body   = 1,
	engine = 1
}

