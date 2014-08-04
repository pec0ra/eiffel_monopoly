class
	SQUARE

inherit

	MONOPOLY_OBJECT

create
	make_with_number

feature {NONE} -- initialization

	make_with_number (n: INTEGER)
			-- Creates the square with number `n'
		require
			n_positive: n >= 0
		do
			position := n
		ensure
			number_set: position = n
		end

feature -- Access

	position: INTEGER
			-- Square's number

feature -- Basic operations

	do_action (p: PLAYER)
			-- Applies the specific action of the square to the player `p'
		require
			p_exist: p /= Void
		do
		end

	set_linked_property (p: like Current)
			-- Set p as linked property
		require
			p /= Void
			p.position = position + 1 or p.position = position - 1
		do
		end

end
