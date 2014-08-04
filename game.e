class
	GAME

inherit

	MONOPOLY_OBJECT

create
	make

feature {NONE} -- Initialization

	make
			-- Create a game
		local
			n, i: INTEGER
			p: PLAYER
			first: BOOLEAN
		do
			first := True

			n := Monopoly_view.request_bounded_value ("Enter number of player between between " + Min_player_count.out + " and " + Max_player_count.out + " :", Min_player_count, Max_player_count)
			create board
			create die_1.make_with_model
			create die_2.make_with_model
			create players.make (0)
			from
				i := 1
			until
				i > n
			loop
				create p.make (Monopoly_view.request_text ("Player " + i.out + " choose your name"), start_money, create {TOKEN}.make_with_color (colors.item (i).color, colors.item (i).relative_x, colors.item (i).relative_y), colors.item (i).color, board)
				p.set_position (1)
				players.extend (p)
				if first then
					current_player := p
					first := False
				end
				i := i + 1
			end
		end

feature -- Basic operations

	play
			-- Start a game.
		do
			players.start
			players.item.info_view.roll_dice_button.show
			players.item.info_view.roll_dice_button.select_actions.extend (agent play_first_round)
		end

	play_first_round
			-- Initialize the first round
		do
			players.start
			Monopoly_view.board_view.extend (Monopoly_view.dice_container)
			players.item.play (die_1, die_2, 1)
		end

	end_game
			-- Finish the game when there's no more player
		local
			i: INTEGER
		do
			if winner /= Void then
				winner.info_view.remove
				if winner.token /= Void and then Monopoly_view.board_view.has (winner.token.view) then
					Monopoly_view.remove_token (winner.token.view)
				end
			end
			across
				players as p
			loop
				p.item.info_view.remove
			end
			players.wipe_out
			from
				i := 1
			until
				i > board.squares.count
			loop
				if attached {PROPERTY_SQUARE} board.squares.item (i) as p then
					p.remove_owner
				end
				i := i + 1
			end
		end

	restart_game
			-- Erase the current game and restart a new one
		local
			n, i: INTEGER
			p: PLAYER
		do
			n := Monopoly_view.request_bounded_value ("Enter number of player between between " + Min_player_count.out + " and " + Max_player_count.out + " :", Min_player_count, Max_player_count)
			from
				i := 1
			until
				i > n
			loop
				create p.make (Monopoly_view.request_text ("Player " + i.out + " choose your name"), start_money, create {TOKEN}.make_with_color (colors.item (i).color, colors.item (i).relative_x, colors.item (i).relative_y), colors.item (i).color, board)
				p.set_position (1)
				players.extend (p)
				i := i + 1
			end
			play
		end

	set_current_player (p: PLAYER)
			-- Set the current player as `p'
		require
			p /= Void
		do
			current_player := p
		ensure
			current_player = p
		end

	set_winner (w: PLAYER)
			-- Set the winnr of the game
		require
			winner_exist: w /= Void
		do
			winner := w
		ensure
			winner_set: winner = w
		end

feature -- Constants

	Min_player_count: INTEGER = 2
			-- Minimum number of players.

	Max_player_count: INTEGER = 6
			-- Maximum number of players.

	Start_money: INTEGER = 1500
			-- The money each player have at the beginning of the game

	colors: ARRAY [TUPLE [color: EV_COLOR; relative_x: INTEGER; relative_y: INTEGER]]
			-- Colors for the tokens
		once
			create Result.make_empty
			Result.force ([create {EV_COLOR}.make_with_rgb (1, 0, 0), -25, 15], 1)
			Result.force ([create {EV_COLOR}.make_with_rgb (0, 1, 0), 25, 15], 2)
			Result.force ([create {EV_COLOR}.make_with_rgb (0, 0, 1), -25, -15], 3)
			Result.force ([create {EV_COLOR}.make_with_rgb (1, 0, 1), 25, -15], 4)
			Result.force ([create {EV_COLOR}.make_with_rgb (0, 0, 0), 0, 15], 5)
			Result.force ([create {EV_COLOR}.make_with_rgb (1, 1, 0), 0, -15], 6)
		end

feature -- Access

	players: ARRAYED_LIST [PLAYER]
			-- Container for players.

	current_player: PLAYER
			-- Payer currently playing

	board: MONOPOLY_BOARD
			-- Board of the game

	die_1: DIE
			-- The first die.

	die_2: DIE
			-- The second die.

	winner: PLAYER
			-- The winner (Void if the game if not over yet).

end
