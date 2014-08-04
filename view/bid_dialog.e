class
	BID_DIALOG

inherit

	BID_DIALOG_IMP

	MONOPOLY_OBJECT
		undefine
			default_create,
			copy
		end

feature {NONE} -- Initialization

	user_create_interface_objects
			-- Create any auxilliary objects needed for BID_DIALOG.
			-- Initialization for these objects must be performed in `user_initialization'.
		do
				-- Create attached types defined in class here, initialize them in `user_initialization'.
		end

	user_initialization
			-- Perform any initialization on objects created by `user_create_interface_objects'
			-- and from within current class itself.
		local
			player_item: EV_LIST_ITEM
			i: INTEGER
			first: BOOLEAN
		do
				-- Initialize types defined in current class
			set_title ("Bid for property")
			button_box.disable_item_expand (ok_button)
			button_box.disable_item_expand (cancel_button)
			set_default_push_button (ok_button)
			ok_button.select_actions.extend (agent on_button_press("OK"))
			cancel_button.select_actions.extend (agent on_button_press("Cancel"))
			create player_items.make (0)
			from
				Game.players.start
				i := 1
				first := True
			until
				Game.players.after
			loop
				if Game.players.item.money /= 0 then
					player_item := create {EV_LIST_ITEM}.make_with_text (Game.players.item.name)
					player_selector.extend (player_item)
					player_items.extend (player_item, "player" + i.out)
					if first then
						player_item.enable_select
						on_select_player (Game.players.item)
						first := False
					end
					player_item.select_actions.extend (agent on_select_player(Game.players.item))
				end
				Game.players.forth
				i := i + 1
			end
		end

feature -- Access

	selected_player: PLAYER
			-- Last selected property

	selected_button: STRING
			-- Last selected button

feature {NONE} -- Implementation

	player_items: HASH_TABLE [EV_LIST_ITEM, STRING]
			-- link between the list item and it's identification

	on_select_player (player: PLAYER)
			-- Action when a property is selected
		require
			player /= Void
		do
			selected_player := player
			price.value_range.adapt (create {INTEGER_INTERVAL}.make (1, player.money))
		end

	on_button_press (a_button_text: READABLE_STRING_GENERAL)
			-- A button with text `a_button_text' has been pressed.
		do
			selected_button := a_button_text.as_string_32
			if not is_destroyed then
				destroy
			end
		end

end
