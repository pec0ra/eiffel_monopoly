class
	TOKEN

inherit

	MONOPOLY_OBJECT

create
	make_with_color

feature -- Initialization

	make_with_color (c: EV_COLOR; x, y: INTEGER)
		require
			c /= Void
		do
			create view.make_with_positions (550 + x, 550 + y, 565 + x, 565 + y)
			color := c
			relative_x := x
			relative_y := y
			view.set_background_color (color)
			Monopoly_view.add_token (view)
		ensure
			view_exist: view /= Void
			color /= Void
		end

feature -- Basic operations

	move_to_position (position: INTEGER)
			-- Move the token to the square at position `p'
		require
			correct_position: position >= 0
		local
			x, y: INTEGER
		do
			if (position - 1) // 5 = 0 then
				x := Board_width - get_square_position (position)
				y := Board_width - (Square_inner_height / 2).truncated_to_integer
			elseif (position - 1) // 5 = 1 then
				x := (Square_inner_height / 2).truncated_to_integer
				y := Board_width - get_square_position (position - 5)
			elseif (position - 1) // 5 = 2 then
				x := get_square_position (position - 10)
				y := (Square_inner_height / 2).truncated_to_integer
			elseif (position - 1) // 5 = 3 then
				x := Board_width - (Square_inner_height / 2).truncated_to_integer
				y := get_square_position (position - 15)
			end
			view.set_point_a_position (x + relative_x, y + relative_y)
			view.set_point_b_position (x + 15 + relative_x, y + 15 + relative_y)
			Monopoly_view.projector.project
		end

	remove
			-- Erase the token from the board
		do
			Monopoly_view.remove_token (view)
		end

feature -- Access

	view: EV_MODEL_ELLIPSE
			-- Representation on the board view

	color: EV_COLOR
			-- Color of the token

feature {NONE} -- Implementation

	relative_x: INTEGER
			-- x position relative to square center

	relative_y: INTEGER
			-- y position relative to square center

	get_square_position (square_number: INTEGER): INTEGER
			-- Returns the position of the square in a line
		require
			square_number >= 0 and square_number <= 5
		do
			if square_number = 1 then
				Result := (Square_height / 2).truncated_to_integer
			else
				Result := Square_height + Square_width.truncated_to_integer // 2 + ((square_number - 2) * Square_width).truncated_to_integer
			end
		end

end
