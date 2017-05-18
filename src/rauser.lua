require("oop")
require("graphics")
require("vector2")

do
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

	rauser.position = vector2(64, 64)
	rauser.velocity = vector2(0, 0)

	rauser.angle = 0
	rauser.thrust = 0
	rauser.gravity = 0

	local sprite = rotatable_sprites.rauser

	function rauser:draw( ... )
		local x = rauser.position.x
		local y = rauser.position.y

		-- camera(x - 64, y - 64)
		-- for i=0,128,16 do
		-- 	for j=0,128,16 do
		-- 		pset(x - 64 + i - x % 16, y - 64 + j - y % 16, 7)
		-- 	end
		-- end
		draw_cached(sprite, x - 8, y - 8, flr(rauser.angle * 16) / 16)
	end

	function rauser:update( ... )
		rauser.gravity += 0.15
		if btn (0) then
			rauser.angle = (rauser.angle + 1/48) % 1
		end
		if btn (1) then
			rauser.angle = (rauser.angle - 1/48) % 1
		end
		if btn (2) then
			rauser.thrust += 2
			rauser.gravity *= 0.01
		end
		rauser.thrust *= 0.25
		rauser.gravity *= 0.7
		rauser.velocity += vector2(rauser.thrust * cos(rauser.angle + 1/4), rauser.thrust * sin(rauser.angle + 1/4))
		rauser.velocity.y += rauser.gravity
		rauser.velocity *= 0.99

		rauser.position += rauser.velocity
		rauser.position %= 128

	end

	function rauser_update( ... )
		rauser:update()
	end

	function rauser_draw( ... )
		cls()
		rauser:draw()
	end
end