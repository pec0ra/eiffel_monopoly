class
	DIE

inherit

	MONOPOLY_OBJECT

create
	make_with_model

feature {NONE} -- Initialization

	make_with_model
			-- Create the dice with apropriate view
		do
			create die_image.make_with_size (60, 60)
			create view.make_with_pixmap (die_image)
			if Monopoly_view.dice_container.count = 0 then
				view.set_point_position (Board_width // 2 - 75, Board_width // 2 - 30)
			else
				view.set_point_position (Board_width // 2 + 15, Board_width // 2 - 30)
			end
			Monopoly_view.dice_container.extend (view)
			roll
		end

feature -- Access

	Face_count: INTEGER = 6
			-- Number of faces.

	face_value: INTEGER
			-- Latest value.

	view: EV_MODEL_PICTURE
			-- Image on the board

	die_image: EV_PIXMAP

feature -- Basic operations

	roll
			-- Roll die.
		do
			random.forth
			face_value := random.bounded_item (1, Face_count)
			if view /= Void then
				die_image.set_with_named_file (Image_path + "die_" + face_value.out + ".png")
			end
		end

feature {NONE} -- Implementation

	random: V_RANDOM
			-- Random sequence.
		once
			create Result
		end

invariant
	face_value_valid: face_value >= 1 and face_value <= Face_count

end
