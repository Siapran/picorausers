-- ################################################################
-- #	MAIN LOOP
-- ################################################################

local update_functions = {
	loading = update_loading
}

local draw_functions = {
	loading = draw_loading
}

function change_state( state )
	gamestate = state
	_update = game_manager
end

function game_manager( )
	_update = update_functions[gamestate]
	_draw = draw_functions[gamestate]
end

function _init( )
	change_state("loading")
end

local angle = 0
-- function _draw()
-- 	-- cls()
-- 	-- angle = (angle + 1/64) % 1

-- 	-- rotate(66, angle, 4)
-- 	-- -- copy_gfx(0x6000, 0x0, 32, 32)
-- 	-- -- cls()

-- 	-- -- spr(0, 0, 0, 16, 4)
-- 	-- pset(0, 0, 7)
-- 	-- pset(31, 31, 7)

-- 	-- print("", 0, 64, 7)
-- 	-- print("angle: " .. angle)
-- 	-- print("cpu: " .. stat(1))

-- 	cls()
-- 	cpu = 0

-- 	-- for i=1,3 do
-- 	-- 	rotate(12, 0.25, 4)
-- 	-- end
-- 	-- cpu = stat(1) - cpu
-- 	-- print("cpu: " .. cpu)

-- 	local count = 0
-- 	while stat(1) < 1 do
-- 		-- rotate(66, 0.25, 2)
-- 		-- copy_gfx(0x0, 0x1000, 128, 16)
-- 		-- memcpy(0X0, 0X1000, 0x400)
-- 		-- spr(0, 0, 0)
-- 		-- cls()
-- 		-- rectfill(0, 0, 128, 128, 0)
-- 		circfill(16, 16, 8, 7)

-- 		count += 1
-- 	end

-- 	cpu = stat(1) - cpu
-- 	print("", 0, 64, 7)
-- 	print("cpu: " .. cpu)
-- 	print("count: " .. count)
-- end

-- local t = 0

-- local cycler = cocreate(function ( )
-- 	while true do
-- 		for i=1,5 do
-- 			rauser.current_type.gun = i
-- 			for j=1,5 do
-- 				rauser.current_type.body = j
-- 				for k=1,5 do
-- 					rauser.current_type.engine = k
-- 					yield()
-- 				end
-- 			end
-- 		end
-- 	end
-- end)

-- printh("----")
-- prerender_all()

-- copy_gfx(0x2000, 0x6000, 128, 64)
-- copy_gfx(0x4400, 0x7000, 128, 64)
-- copy_gfx(0x4400, 0x6000, 128, 128)

-- function _draw()
-- 	t = t + 1
-- 	if t % 4 == 0 then
-- 		angle = (angle + 1/16) % 1
-- 	end

-- 	if t % 10 == 0 then
-- 		coresume(cycler)
-- 	end

-- 	cls()
-- 	rotatable_sprites.ace.render_func(0, angle)
-- end

