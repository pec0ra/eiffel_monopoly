class
	TAX_SQUARE

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
			tax: REAL_64
		do
			tax := p.money * 0.01
			tax := tax.floor * 10
			Monopoly_view.break ("Tax square ! You must pay " + tax.truncated_to_integer.out + " CHF.")
			p.add_money (- tax.truncated_to_integer)
		end

end
