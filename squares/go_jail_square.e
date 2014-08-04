class
	GO_JAIL_SQUARE

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
		do
			Monopoly_view.break ("You go to jail without going through go")
			p.put_in_jail
		end
end
