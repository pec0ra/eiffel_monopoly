class
	HOUSES_DIALOG

inherit

	HOUSES_DIALOG_IMP

feature {NONE} -- Initialization

	user_create_interface_objects
			-- Create any auxilliary objects needed for HOUSES_DIALOG.
			-- Initialization for these objects must be performed in `user_initialization'.
		do
				-- Create attached types defined in class here, initialize them in `user_initialization'.
		end

	user_initialization
			-- Perform any initialization on objects created by `user_create_interface_objects'
			-- and from within current class itself.
		do
			set_title ("Buy / Sell houses")
			button_box.disable_item_expand (ok_button)
			button_box.disable_item_expand (cancel_button)
			set_default_push_button (ok_button)
			ok_button.select_actions.extend (agent on_button_press("OK"))
			cancel_button.select_actions.extend (agent on_button_press("Cancel"))
		end

feature -- Basic operations

	add_info_from_player (p: PLAYER)
			-- Fill the dialog according to player `p' informations
		require
			p /= Void
		local
			property: EV_LIST_ITEM
			i: INTEGER
			first: BOOLEAN
		do
			player := p
			create properties_item.make (0)
			from
				p.properties.start
				i := 1
				first := True
			until
				p.properties.after
			loop
				if (p.money >= p.properties.item.house_price or p.properties.item.house_count >= 1) and (p.properties.item.linked_square = Void or else p.properties.has (p.properties.item.linked_square)) then
					property := create {EV_LIST_ITEM}.make_with_text (p.properties.item.name + " ( " + p.properties.item.house_count.out + " h. )")
					property.set_identifier_name ("property" + i.out)
					property_selector.extend (property)
					properties_item.extend (property, "property" + i.out)
					if first then
						property.enable_select
						on_select_property (p.properties.item)
						first := False
					end
					property.select_actions.extend (agent on_select_property(p.properties.item))
				end
				p.properties.forth
				i := i + 1
			end
		end

feature -- Access

	selected_property: PROPERTY_SQUARE
			-- Last selected property

	selected_button: STRING
			-- Last selected button

feature {NONE} -- Implementation

	properties_item: HASH_TABLE [EV_LIST_ITEM, STRING]

	player: PLAYER
			-- Player who will buy or sell houses

	on_select_property (property: PROPERTY_SQUARE)
			-- Action when a property is selected
		require
			property /= Void
		do
			selected_property := property
			buy_button.hide
			sell_button.hide
				-- Sell button
			if property.house_count >= 1 then
				sell_button.show
				sell_button.enable_select
				sell_button.select_actions.extend (agent on_sell_selected(property))
				house_number.value_range.adapt (create {INTEGER_INTERVAL}.make (1, property.house_count))
			end
				-- Buy button
			if player.money >= property.house_price and property.house_count < 5 then
				buy_button.enable_select
				buy_button.show
				house_number.value_range.adapt (create {INTEGER_INTERVAL}.make (1, (5 - property.house_count).min (player.money // property.house_price)))
				buy_button.select_actions.extend (agent on_buy_selected(property))
			end
			house_number.change_actions.extend (agent on_value_change)
			on_value_change (house_number.value)
		end

	on_buy_selected (property: PROPERTY_SQUARE)
			-- when buy is selected
		require
			property /= Void
		do
			house_number.value_range.adapt (create {INTEGER_INTERVAL}.make (1, (5 - property.house_count).min (player.money // property.house_price)))
			on_value_change (house_number.value)
		end

	on_sell_selected (property: PROPERTY_SQUARE)
			-- when buy is selected
		require
			property /= Void
		do
			house_number.value_range.adapt (create {INTEGER_INTERVAL}.make (1, property.house_count))
			on_value_change (house_number.value)
		end

	on_value_change (i: INTEGER)
			-- When the house number is changed
		local
			house_price: INTEGER
		do
			house_price := selected_property.house_price
			if sell_button.is_selected then
				house_price := (0.7 * house_price).truncated_to_integer
			end
			price_info.set_text (i.out + " * " + house_price.out + " CHF = " + (i * house_price).out + " CHF")
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
