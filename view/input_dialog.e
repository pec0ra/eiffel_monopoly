class
	INPUT_DIALOG

inherit
	INPUT_DIALOG_IMP

	EV_DIALOG_CONSTANTS
		export
			{NONE} all
		undefine
			default_create, copy
		end
create
	make_with_text

feature {NONE} -- Initialization

	make_with_text (a_text: STRING)
			-- Create `Current' and assign `a_text' to `text'.
		require
			a_text_not_void: a_text /= Void
		do
			default_create
			button_box.disable_item_expand (ok_button)
			set_default_push_button (ok_button)
			ok_button.select_actions.extend (agent on_button_press (ev_ok))
			set_text (a_text)
		end


feature {NONE} -- Initialization

	user_create_interface_objects
			-- Create any auxilliary objects needed for INPUT_DIALOG.
			-- Initialization for these objects must be performed in `user_initialization'.
		do
				-- Create attached types defined in class here, initialize them in `user_initialization'.
		end

	user_initialization
			-- Perform any initialization on objects created by `user_create_interface_objects'
			-- and from within current class itself.
		do
				-- Initialize types defined in current class
		end

feature -- Access

	selected_button: STRING
			-- Last clicked button

feature {NONE} -- Implementation

	set_text (a_text: STRING)
			-- Set `a_text' as label
		require
			not_destroyed: not is_destroyed
			a_text_not_void: a_text /= Void
		do
			text.set_text (a_text)
		ensure
			text_set: text.text ~ a_text
			clone: text.text /= a_text
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
