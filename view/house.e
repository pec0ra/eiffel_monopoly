class
	HOUSE

inherit

	MONOPOLY_OBJECT

create
	make_with_square

feature {NONE} -- Initialization

	make_with_square (s: PROPERTY_SQUARE; n: INTEGER)
			-- Initialization for `Current'.
		require
			s /= Void
			n >= 0 and n <= 5
		do
			house_number := n
			create_house
			put_to_position (s.position)
			view.set_background_color (create {EV_COLOR}.make_with_rgb (1, 0, 0))
		ensure
			view /= Void
		end

feature -- Access

	view: EV_MODEL_POLYGON

feature -- Basic operation

	put_to_position (position: INTEGER)
			-- move the house to a square_number `p'
		require
			position >= 0 and position <= 20
		local
			x, y: INTEGER
		do
			if (position - 1) // 5 = 0 then
				x := Board_width - get_square_position (position)
				y := Board_width - (Square_inner_height + 5)
			elseif (position - 1) // 5 = 1 then
				x := Square_inner_height + 10
				y := Board_width - get_square_position (position - 5) + 5
			elseif (position - 1) // 5 = 2 then
				x := get_square_position (position - 10)
				y := Square_inner_height + 15
			elseif (position - 1) // 5 = 3 then
				x := Board_width - (Square_inner_height + 15)
				y := get_square_position (position - 15) + 7
			end
			view.set_i_th_point_position (1, x_1 + x, y_1 + y)
			view.set_i_th_point_position (2, x_2 + x, y_2 + y)
			view.set_i_th_point_position (3, x_3 + x, y_3 + y)
		end

	show
			-- Shows the house on the board
		do
			if not Monopoly_view.board_view.has (view) then
				Monopoly_view.board_view.extend (view)
				Monopoly_view.projector.project
			end
		ensure
			Monopoly_view.board_view.has (view)
		end

	hide
			-- Hide the house from the board
		do
			if Monopoly_view.board_view.has (view) then
				Monopoly_view.board_view.prune_all (view)
				Monopoly_view.projector.project
			end
		ensure
			not Monopoly_view.board_view.has (view)
		end

feature -- Constants

	x_1: INTEGER = -7

	y_1: INTEGER = 0

	x_2: INTEGER = 7

	y_2: INTEGER = 0

	x_3: INTEGER = 0

	y_3: INTEGER = -12

feature {NONE} -- Implementation

	house_number: INTEGER
			-- `house_number''s house of the square

	create_house
			-- Create a model for the house
		local
			coord: ARRAY [EV_COORDINATE]
		do
			create coord.make_empty
			coord.force (create {EV_COORDINATE}.make (x_1, y_1), 1)
			coord.force (create {EV_COORDINATE}.make (x_2, y_2), 2)
			coord.force (create {EV_COORDINATE}.make (x_3, y_3), 3)
			create view.make_with_coordinates (coord)
		end

	get_square_position (p: INTEGER): INTEGER
			-- Get the coordinate of the square at position `p'
		require
			p >= 2 and p <= 5
		do
			Result := Square_height + ((p - 2) * Square_width).truncated_to_integer + 16 * (house_number) + 5
		ensure
			Result >= 0 and Result <= Board_width
		end

end
