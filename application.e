class
	APPLICATION

inherit

	EV_APPLICATION

	MONOPOLY_OBJECT
		undefine
			default_create,
			copy
		end

create
	make_and_launch

feature {NONE} -- Initialization

	make_and_launch
			-- Initialize and launch application
		do
			default_create
			prepare
			launch
		end

	prepare
			-- Prepare the first window to be displayed.
			-- Perform one call to first window in order to
			-- avoid to violate the invariant of class EV_APPLICATION.

		do
			Monopoly_view.main_window.new_game_menu.select_actions.extend (agent new_game)
		end

feature -- Implementation

	new_game
			-- Creates a new game `Game' and starts it
		do
			Monopoly_view.main_window.new_game_menu.select_actions.wipe_out
			Game.play
			Monopoly_view.main_window.new_game_menu.select_actions.extend (agent restart_game)
			Monopoly_view.main_window.menu_box.extend (Monopoly_view.main_window.end_game_menu)
			Monopoly_view.main_window.end_game_menu.select_actions.extend (agent end_game)
		end

	restart_game
			-- End the current game and restart a new one
		do
			end_game
			Game.restart_game
			Monopoly_view.main_window.menu_box.extend (Monopoly_view.main_window.end_game_menu)
		end

	end_game
			-- End the current game
		do
			Game.players.wipe_out
			Monopoly_view.clean_console
			Monopoly_view.main_window.player_info_box.wipe_out
			Monopoly_view.clean_board
			Monopoly_view.projector.project
			Game.end_game
			Monopoly_view.main_window.menu_box.prune_all (Monopoly_view.main_window.end_game_menu)
		end

end -- class APPLICATION
