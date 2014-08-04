class
	PLAYER_INFO_VIEW

inherit
	MONOPOLY_OBJECT

create
	make_with_player

feature -- Initialization
	make_with_player ( p: PLAYER; color: EV_COLOR)
			-- Create view
		require
			p /= Void
			Monopoly_view.main_window /= Void and not Monopoly_view.main_window.is_destroyed
		local
			vertical_box: EV_VERTICAL_BOX
		do
			player := p

			create frame.make_with_text (player.name)
			frame.set_minimum_width (300)
			frame.set_background_color (color)

			create vertical_box
			create button_box

			create label
			update_label

			create roll_dice_button.make_with_text ("Roll dice")
			roll_dice_button.hide
			create house_option_button.make_with_text ("Buy / Sell houses")
			create sell_property_button.make_with_text ("Sell property")
			create pay_fine_button.make_with_text ("Pay 50 CHF fine")
			sell_property_button.hide
			pay_fine_button.hide
			button_box.extend (house_option_button)
			button_box.extend (sell_property_button)
			button_box.extend (pay_fine_button)
			button_box.extend (roll_dice_button)

			vertical_box.extend (label)
			vertical_box.extend (button_box)
			vertical_box.disable_item_expand (button_box)
			button_box.disable_item_expand (roll_dice_button)
			button_box.disable_item_expand (house_option_button)

			frame.extend (vertical_box)
			Monopoly_view.main_window.player_info_box.extend (frame)
		end

feature -- Access

	label: EV_LABEL
			-- Label where the text is displayed

	frame: EV_FRAME

	player: PLAYER
			-- Name of the player

	button_box: EV_HORIZONTAL_BOX
			-- Box containing buttons

	roll_dice_button: EV_BUTTON
			-- Button to roll the dice

	house_option_button: EV_BUTTON
			-- Buttonto add or delete houses

	sell_property_button: EV_BUTTON
			-- Button to sell property

	pay_fine_button: EV_BUTTON
			-- Button to pay the fine

feature -- Basic operations

	update_label
			-- updates the label text
		local
			text: STRING
		do
			if player.turns_left_in_jail = 0 then
				text := "Money : " + player.money.out + " CHF%NTurns left in jail : " + player.turns_left_in_jail.out
			else
				text := "Money : " + player.money.out + " CHF%NTurns left in jail : " + (player.turns_left_in_jail - 1).out
			end
			label.set_text (text)
		end

	remove
			-- Remove the info_view
	do
		Monopoly_view.main_window.player_info_box.prune_all (frame)
	end

end
