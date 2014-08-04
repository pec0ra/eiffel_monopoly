class
	MAIN_WINDOW

inherit
	MAIN_WINDOW_IMP
	MONOPOLY_OBJECT
		undefine
			default_create,
			copy
		end


feature {NONE} -- Initialization

	user_create_interface_objects
			-- Create any auxilliary objects needed for MAIN_WINDOW.
			-- Initialization for these objects must be performed in `user_initialization'.
		do
				-- Create attached types defined in class here, initialize them in `user_initialization'.
		end

	user_initialization
			-- Perform any initialization on objects created by `user_create_interface_objects'
			-- and from within current class itself.
		do
				menu_box.prune_all (about_menu)
				menu_box.prune_all (end_game_menu)
		end
end
