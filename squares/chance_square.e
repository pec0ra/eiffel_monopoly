class
	CHANCE_SQUARE

inherit
	SQUARE
		redefine
			do_action
		end
create
	make_with_number

feature -- Basic operatin

	do_action (p: PLAYER)
			-- Applies the specific action of the square to the player `p'
		local
			r: V_RANDOM
			tax: INTEGER
			message: STRING
		do
			create r.default_create
			r.forth
			tax := r.bounded_item (-30, 20) * 10

			if tax >= 0 then
				message := "You win " + tax.out + " CHF."
			else
				message := "You loose " + (- tax).out + " CHF."
			end
			Monopoly_view.break ("Chance ! " + message)
			p.add_money (tax)

		end
end
