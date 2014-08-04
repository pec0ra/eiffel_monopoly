deferred class
	MONOPOLY_OBJECT

inherit

	BOARD_CONSTANTS

feature -- Access

	Monopoly_view: GRAPHICAL_VIEW
			-- The GUI available in all monopoly objects
		once
			create {GRAPHICAL_VIEW} Result.make
		end

	Game: GAME
			-- The current game
		once
			create {GAME} Result.make
		end

end
