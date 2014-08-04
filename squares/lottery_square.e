note
	description: "Summary description for {LOTTERY_SQUARE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LOTTERY_SQUARE

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
			p.set_money (p.money + 10)
			print ("Lottery square, you get 10 CHF ! ")
		end

end
