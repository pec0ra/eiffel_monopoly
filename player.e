class
	PLAYER

inherit

	MONOPOLY_OBJECT

create
	make

feature {NONE} -- Initialization

	make (n: STRING; m: INTEGER; t: TOKEN; color: EV_COLOR; b: MONOPOLY_BOARD)
			-- Create a player with name `n' and `m' CHF.
		require
			name_exists: n /= Void and then not n.is_empty
			m_positive: m >= 0
			b_exists: b /= Void and then b.Square_count > 0
			token_exist: t /= Void
		do
			name := n.twin
			money := m
			board := b
			token := t
			Monopoly_view.add_token (token.view)
			create info_view.make_with_player (Current, color)
			info_view.house_option_button.select_actions.extend (agent house_options)
			create properties.make (0)
		ensure
			name_set: name ~ n
			money_set: money = m
			t /= Void
		end

feature -- Access

	name: STRING
			-- Player name.

	position: INTEGER
			-- Current position on the board.

	money: INTEGER
			-- Current money of the player

	has_lost: BOOLEAN

	board: MONOPOLY_BOARD
			-- Board of the current game

	turns_left_in_jail: INTEGER
			-- Turns the player must still wait before going out of jail

	properties: ARRAYED_SET [PROPERTY_SQUARE]
			-- Properties the player own

	token: TOKEN
			-- Token of the player

	info_view: PLAYER_INFO_VIEW

feature -- Moving

	set_position (pos: INTEGER)
			-- Set position to `pos'.
		require
			correct_position: pos >= 0 and pos - board.Square_count <= board.Square_count
		do
			if pos > board.Square_count then
				position := pos - board.Square_count
			else
				position := pos
			end
			token.move_to_position (position)
		ensure
			correct_position: position >= 1 and position <= board.Square_count
		end

	move (dice_value: INTEGER)
			-- Move the player and execute action of the square
		require
			correct_value: dice_value >= 2 and dice_value <= 12
		local
			new_position: INTEGER
		do
			new_position := position + dice_value
			set_position (new_position)
			if new_position > board.Square_count then
				add_money (150)
				Monopoly_view.break ("You pass through go, you collect 150 CHF")
			end
			board.squares.item (position).do_action (Current)
		end

feature -- Basic operations

	play (d1, d2: DIE; double_count: INTEGER)
			-- Play a turn with dice `d1', `d2'.
		require
			dice_exist: d1 /= Void and d2 /= Void
			double_count >= 1 and double_count <= 3
		do
			if not has_lost then
				Game.set_current_player (Current)
				info_view.update_label
				info_view.roll_dice_button.hide
				info_view.roll_dice_button.select_actions.wipe_out
				info_view.sell_property_button.hide
				info_view.sell_property_button.select_actions.wipe_out
				info_view.pay_fine_button.hide
				info_view.pay_fine_button.select_actions.wipe_out
				Monopoly_view.clean_console
				d1.roll
				d2.roll
				if d1.face_value = d2.face_value and double_count = 3 then
					Monopoly_view.break ("Third double, you go directly to jail !")
					put_in_jail
				elseif turns_left_in_jail = 0 then
					move (d1.face_value + d2.face_value)
				else
					if d1.face_value = d2.face_value then
						Monopoly_view.break ("Double ! You are lucky today and you go out of jail !")
						turns_left_in_jail := 0
						move (d1.face_value + d2.face_value)
					else
						if turns_left_in_jail = 1 then
							pay_fine
							move (d1.face_value + d2.face_value)
						else
							turns_left_in_jail := turns_left_in_jail - 1
							Monopoly_view.break ("Still " + (turns_left_in_jail - 1).out + " turns in jail.")
						end
					end
				end
			end
			finish_turn (d1, d2, double_count)
		end

	finish_turn (d1, d2: DIE; double_count: INTEGER)
			-- Set things up for the next turn
		local
			next_player: PLAYER
			player_index: INTEGER
		do
			info_view.update_label
			if d1.face_value = d2.face_value and turns_left_in_jail = 0 and not has_lost then
				Monopoly_view.break ("You had a double, you play again !")
				info_view.roll_dice_button.show
				info_view.roll_dice_button.select_actions.extend (agent play(d1, d2, double_count + 1))
				if properties.count >= 1 then
					info_view.sell_property_button.show
					info_view.sell_property_button.select_actions.extend (agent sell_property_options)
				end
			else
				player_index := Game.players.index_of (Current, 1)
				if player_index = Game.players.count then
					next_player := Game.players.i_th (1)
				else
					next_player := Game.players.i_th (player_index + 1)
				end
				Monopoly_view.print_text ("" + next_player.name + "'s turn.")
				next_player.info_view.roll_dice_button.show
				next_player.info_view.roll_dice_button.select_actions.extend (agent next_player.play(d1, d2, 1))
				if next_player.properties.count >= 1 then
					next_player.info_view.sell_property_button.show
					next_player.info_view.sell_property_button.select_actions.extend (agent next_player.sell_property_options)
				end
				if next_player.turns_left_in_jail >= 1 then
					next_player.jail_options
				end
			end
			if has_lost then
				if Game.players.count = 2 then
					info_view.remove
					Monopoly_view.remove_token (token.view)
					Game.players.prune_all (Current)
					Game.players.start
					Game.set_winner (Game.players.item)
					Monopoly_view.break ("The winner is " + Game.winner.name)
					Game.end_game
				else
					info_view.remove
					Monopoly_view.remove_token (token.view)
					Game.players.prune_all (Current)
				end
			end
		end

	add_money (m: INTEGER)
			-- Add `m' to player's money
		do
			if money + m >= 0 then
				money := money + m
				info_view.update_label
			else
				if properties.count /= 0 then
					recover_actions (- m)
					if not has_lost and money >= m then
						money := money + m
					else
						has_lost := True
					end
				else
					has_lost := True
				end
			end
		end

	pay_to_player (m: INTEGER; p: PLAYER)
			-- Pay `m' to player `p'
		require
			p /= Void
			m >= 0
		do
			if money >= m then
				add_money (- m)
				p.add_money (m)
			else
				if properties.count /= 0 then
					recover_actions (m)
					if money >= m then
						add_money (- m)
						p.add_money (m)
					else
						p.add_money (money)
						add_money (- money)
						has_lost := True
					end
				else
					add_money (- money)
					p.add_money (money)
					has_lost := True
				end
			end
		end

	add_property (p: PROPERTY_SQUARE)
			-- Add `p' to player's properties
		require
			p /= Void
		do
			properties.extend (p)
		end

	put_in_jail
			-- The player will be in jail for 3 turns
		do
			turns_left_in_jail := 4
			set_position (board.jail_position)
		ensure
			turns_left_in_jail = 4
		end

	recover_actions (m: INTEGER)
			-- When a player is in dept, he can try to sell his houses and properties
		require
			money < m
		local
			modal: LOST_DIALOG
		do
			create modal
			modal.add_player_info (Current, m)
			modal.show_modal_to_window (Monopoly_view.main_window)
			if money < m and properties.count /= 0 then
				if modal.selected_button ~ "Abandon" then
					has_lost := True
				end
				if not (modal.selected_button ~ "Abandon" and Game.players.count <= 2) then
					Monopoly_view.break ("Your properties will be sold to the best bidder")
					from
						properties.start
					until
						properties.after
					loop
						properties.item.sell_to_best_bidder
						properties.forth
					end
				end
				if properties.count /= 0 then
					from
						properties.start
					until
						properties.count = 0
					loop
						properties.item.remove_owner
						properties.remove
						properties.start
					end
				end
			end
		end

	jail_options
			-- Actions to perform when player is in jail
		require
			turns_left_in_jail >= 1
		do
			info_view.pay_fine_button.show
			info_view.pay_fine_button.select_actions.extend (agent pay_fine)
			info_view.pay_fine_button.select_actions.extend (agent play(Game.die_1, Game.die_2, 1))
		end

	pay_fine
			-- Pay the fine to go out of jail
		require
			turns_left_in_jail >= 1
		do
			add_money (-50)
			turns_left_in_jail := 0
			Monopoly_view.break ("You pay a 50 CHF fine")
		end

	house_options
			-- Let the player proceed to option regarding his houses
		local
			property: PROPERTY_SQUARE
			modal: HOUSES_DIALOG
		do
			if properties.count >= 1 and properties.to_array.there_exists (agent can_have_houses(?)) then
				create modal
				modal.add_info_from_player (Current)
				modal.show_modal_to_window (Monopoly_view.main_window)
				if modal.selected_button /= Void and then modal.selected_button ~ (create {EV_DIALOG_CONSTANTS}).ev_ok then
					property := modal.selected_property
					if modal.buy_button.is_selected then
						property.add_house (modal.house_number.value)
					elseif modal.sell_button.is_selected then
						property.sell_house (modal.house_number.value)
					end
				end
			else
				Monopoly_view.break ("You are unable to add houses")
			end
		end

	sell_property_options
			-- Let the player sell properties
		require
			properties.count >= 1
		local
			property: PROPERTY_SQUARE
			modal: PROPERTY_DIALOG
			bid_result: TUPLE [player: PLAYER; price: INTEGER]
		do
			create modal
			modal.add_info_from_player (Current)
			modal.show_modal_to_window (Monopoly_view.main_window)
			if modal.selected_button /= Void and then modal.selected_button ~ (create {EV_DIALOG_CONSTANTS}).ev_ok then
				property := modal.selected_property
				bid_result := property.bid
				if bid_result /= Void and bid_result.player /= Void then
					if property.house_count >= 1 then
						property.sell_house (property.house_count)
					end
					bid_result.player.pay_to_player (bid_result.price, Current)
					property.set_owner (bid_result.player)
					properties.prune_all (property)
					bid_result.player.properties.extend (property)
					Monopoly_view.break ("You sold " + property.name + " to " + bid_result.player.name + " for " + bid_result.price.out + " CHF")
					if properties.count = 0 then
						info_view.sell_property_button.select_actions.wipe_out
						info_view.sell_property_button.hide
					end
				end
			end
		end



	sell_property
			-- Let the user sell a property
		require
			properties.count > 0
		do
		end

feature {NONE} -- Implementation

	has_money (p: PLAYER): BOOLEAN
			-- Checks if a player has still money
		require
			p /= Void
		do
			Result := p.money > 0
		end

	can_have_houses (p: PROPERTY_SQUARE): BOOLEAN
			-- Checks if the player is able to add houses to `p'
		require
			p /= Void
		do
			if money >= p.house_price or p.house_count >= 1 then
				if p.linked_square = Void or else properties.has (p.linked_square) then
					Result := True
				else
					Result := False
				end
			else
				Result := False
			end
		end

invariant
	name_exists: name /= Void and then not name.is_empty
	turns_positive: turns_left_in_jail >= 0

end
