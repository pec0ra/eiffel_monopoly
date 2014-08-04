class
	GRAPHICAL_VIEW

inherit

	MONOPOLY_OBJECT

	EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		local
			background_image: EV_PIXMAP
		do
			create main_window
			main_window.set_title ("Monopoly")
			main_window.board_pixmap.set_minimum_size (Board_width, Board_width)
			create board_view
			create background_image
			background_image.set_minimum_width (Board_width)
			background_image.set_minimum_height (Board_width)
			background_image.set_with_named_file (Image_path + "board.png")
			create background.make_with_pixmap (background_image)
			board_view.extend (background)
			create dice_container.default_create
			create projector.make (board_view, main_window.board_pixmap)
			projector.project

				-- We don't need it anymore
			main_window.console.hide
			main_window.show
		end

feature -- Access

	main_window: MAIN_WINDOW
			-- Main application window

	projector: EV_MODEL_PIXMAP_PROJECTOR

	board_view: EV_MODEL_WORLD

	dice_container: EV_MODEL_GROUP

	background: EV_MODEL_PICTURE

	token: EV_MODEL_ELLIPSE

feature -- Basic operation

	add_token (t: EV_MODEL_ELLIPSE)
		do
			board_view.extend (t)
			projector.project
		end

	remove_token (t: EV_MODEL_ELLIPSE)
		require
			t /= Void
			board_view.has (t)
		do
			board_view.prune_all (t)
			projector.project
		end

	print_text (text: STRING)
		require
			text /= Void
		do
			main_window.console.set_text (main_window.console.text + "%N" + text)
		end

	clean_console
		do
			main_window.console.set_text ("Output :")
		end

	break (text: STRING)
			-- Makes a pause
		local
			modal: EV_INFORMATION_DIALOG
		do
			clean_console
			create modal.make_with_text (text)
			modal.set_title (Game.current_player.name)
			modal.show_modal_to_window (main_window)
		end

	clean_board
		do
			board_view.wipe_out
			board_view.extend (background)
			projector.project
		end

	request_bounded_value (text: STRING; min: INTEGER; max: INTEGER): INTEGER
			-- Ask the user to enter a value between `min' and `max' with a print of the form ' `text' '
		local
			modal: INTEGER_INPUT_DIALOG
		do
			create modal.make_with_text (text)
			modal.int_field.value_range.adapt (create {INTEGER_INTERVAL}.make (min, max))
			modal.show_modal_to_window (main_window)
			if modal.selected_button /= Void and then modal.selected_button ~ (create {EV_DIALOG_CONSTANTS}).ev_ok then
				if attached {INTEGER} modal.int_field.value as user_input then
					Result := user_input
				else
					Result := request_bounded_value (text, min, max)
				end
			end
		end

	request_text (text: STRING): STRING
			-- Ask the user to enter a text showing him `text'
		require
			text /= Void
		local
			modal: INPUT_DIALOG
		do
			create modal.make_with_text (text)
			modal.input_field.set_capacity (30)
			modal.set_title ("Enter value")
			modal.show_modal_to_window (main_window)
			if modal.selected_button /= Void then
				if modal.input_field = Void or else modal.input_field.text.is_empty then
					Result := request_text (text)
				else
					Result := modal.input_field.text
				end
			else
				Result := request_text (text)
			end
		end

	confirm (text: STRING): BOOLEAN
			-- Ask the user to confirm `text'
		local
			modal: EV_CONFIRMATION_DIALOG
		do
			create modal.make_with_text (text)
			modal.set_title (Game.current_player.name + " - Confirmation")
			modal.show_modal_to_window (main_window)
			if modal.selected_button /= Void and then modal.selected_button ~ (create {EV_DIALOG_CONSTANTS}).ev_ok then
				Result := True
			else
				Result := False
			end
		end

end
