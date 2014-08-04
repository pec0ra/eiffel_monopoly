class
	LOST_DIALOG

inherit

	LOST_DIALOG_IMP

	MONOPOLY_OBJECT
		undefine
			default_create,
			copy
		end

feature {NONE} -- Initialization

	user_create_interface_objects
			-- Create any auxilliary objects needed for LOST_DIALOG.
			-- Initialization for these objects must be performed in `user_initialization'.
		do
				-- Create attached types defined in class here, initialize them in `user_initialization'.
		end

	user_initialization
			-- Perform any initialization on objects created by `user_create_interface_objects'
			-- and from within current class itself.
		do
				-- Initialize types defined in current class
			set_title ("Out of money")
			button_box1.disable_item_expand (sell_houses_button)
			button_box1.disable_item_expand (sell_properties_button)
			button_box2.disable_item_expand (cancel_button)
			set_default_push_button (sell_houses_button)
			sell_houses_button.select_actions.extend (agent sell_houses)
			sell_properties_button.select_actions.extend (agent sell_properties)
			cancel_button.select_actions.extend (agent abandon)
		end

feature -- Basic operation

	add_player_info (p: PLAYER; m: INTEGER)
			-- add info from player and the amount `m' the player tries to get
		require
			p /= Void
			m > 0
		do
			player := p
			amount := m
		ensure
			player = p
		end

feature -- Access

	selected_button: STRING
			-- Last selected button

feature {NONE} -- Implementation

	player: PLAYER
			-- player who is out of money

	amount: INTEGER
			-- amount the player tries to get

	sell_properties
			-- Sell properties
		require
			player /= Void
			player.properties.count /= 0
		do
			if Game.players.there_exists (agent has_money(?)) then
				player.sell_property_options
				if player.money >= amount then
					finish_recover_action
				end
			else
				Monopoly_view.break ("Nobody can aford your property")
			end
		end

	sell_houses
			-- Sell houses
		require
			player /= Void
		do
			player.house_options
			if player.money >= amount then
				finish_recover_action
			end
		end

	abandon
			-- Abandon
		do
			if Monopoly_view.confirm ("Are you sure you want to proceed ? You will be out of the game.") then
				selected_button := "Abandon"
				finish_recover_action
			end
		end

	finish_recover_action
			-- Quit the modal
		do
			if not is_destroyed then
				destroy
			end
		end

	has_money (p: PLAYER): BOOLEAN
			-- Checks if a player has still money
		require
			p /= Void
		do
			Result := p.money > 0
		end

end
