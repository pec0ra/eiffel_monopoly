note
	description: "Summary description for {BAD_SQUARE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BAD_SQUARE

inherit

	SQUARE
		redefine
			do_action
		end

create
	make_with_number

feature -- Basic operations

	do_action (p: PLAYER)
			-- Applies the specific action of the square to the player `p'
		do
			p.set_money (p.money - 5)
			print ("Bad square, you lose 5 CHF ! ")
		end

end
