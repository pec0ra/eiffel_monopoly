deferred class
	BOARD

feature -- Access

	Square_count: INTEGER
			-- Number of square
		deferred
		end

	squares: V_ARRAY [SQUARE]
			-- Container for squares
		deferred
		end

end
