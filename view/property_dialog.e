class
	PROPERTY_DIALOG

inherit
	PROPERTY_DIALOG_IMP


feature {NONE} -- Initialization

	user_create_interface_objects
			-- Create any auxilliary objects needed for PROPERTY_DIALOG.
			-- Initialization for these objects must be performed in `user_initialization'.
		do
				-- Create attached types defined in class here, initialize them in `user_initialization'.
		end

	user_initialization
			-- Perform any initialization on objects created by `user_create_interface_objects'
			-- and from within current class itself.
		do
				-- Initialize types defined in current class

				set_title ("Sell properties")

				button_box.disable_item_expand (ok_button)
				button_box.disable_item_expand (cancel_button)
				set_default_push_button (ok_button)
				ok_button.select_actions.extend (agent on_button_press ("OK"))
				cancel_button.select_actions.extend (agent on_button_press ("Cancel"))
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
				property := create {EV_LIST_ITEM}.make_with_text (p.properties.item.name)
				property.set_identifier_name ("property" + i.out)
				property_selector.extend (property)
				properties_item.extend (property, "property" + i.out)
				if first then
					property.enable_select
					on_select_property (p.properties.item)
					first := False
				end
				property.select_actions.extend (agent on_select_property (p.properties.item))

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
			price_info.set_text ("This property is worth " + property.price.out)
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
