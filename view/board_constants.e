class
	BOARD_CONSTANTS

feature -- Constants

	Board_width: INTEGER = 600

	Board_height: INTEGER = 600

	Square_height: INTEGER = 109

	Square_width: REAL = 95.4

	Square_inner_height: INTEGER = 84

	Image_path: STRING
		once
			Result := "images" + operating_environment.directory_separator.out
		end

end
