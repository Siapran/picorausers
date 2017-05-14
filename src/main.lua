require("graphics")
require("rauser")

timeref = 0

do
	local update_functions = {
		loading = update_loading,
		rauser_test = rauser_update,
	}

	local draw_functions = {
		loading = draw_loading,
		rauser_test = rauser_draw,
	}

	function change_state( state )
		gamestate = state
		_update = update_functions[gamestate]
		_draw = draw_functions[gamestate]
	end

	function _init( )
		change_state("loading")
	end
end
