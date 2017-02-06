require("graphics")

-- ################################################################
-- #	MAIN LOOP
-- ################################################################
timeref = 0

do
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
end
