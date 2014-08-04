class
	MONOPOLY_BOARD

inherit

	BOARD


feature -- Access

	Square_count: INTEGER = 20

	jail_position: INTEGER = 6

	squares: V_ARRAY [SQUARE]
		local
			i: INTEGER
		once
			create Result.make_filled (1, Square_count, create {SQUARE}.make_with_number (0))
			from
				i := 1
			until
				i > Square_count
			loop
				if properties [i].position /= 0 then
					Result.put (create {PROPERTY_SQUARE}.make_with_tuple (properties [i]), i)
				elseif i = 1 then
					Result.put (create {GO_SQUARE}.make_with_number (i), i)
				elseif i = 4 then
					Result.put (create {TAX_SQUARE}.make_with_number (i), i)
				elseif i = jail_position then
					Result.put (create {JAIL_SQUARE}.make_with_number (i), i)
				elseif i = 9 or i = 13 or i = 19 then
					Result.put (create {CHANCE_SQUARE}.make_with_number (i), i)
				elseif i = 16 then
					Result.put (create {GO_JAIL_SQUARE}.make_with_number (i), i)
				else
					Result.put (create {SQUARE}.make_with_number (i), i)
				end
				i := i + 1
			end
			from
				properties.start
			until
				properties.after
			loop
				if properties.item.linked /= 0 then
					squares.item (properties.item.position).set_linked_property (squares.item (properties.item.linked))
				end
				properties.forth
			end
		end

	properties: ARRAYED_LIST [TUPLE [position: INTEGER; name: STRING; price: INTEGER; rent: INTEGER; linked: INTEGER]]
			-- List of properties and values
		local
			p_array: ARRAY [TUPLE [position: INTEGER; name: STRING; price: INTEGER; rent: INTEGER; linked: INTEGER]]
		once
			create p_array.make_filled ([0, "", 0, 0, 0], 1, Square_count)
			p_array.put ([2, "Dübendorfstrasse", 60, 4, 3], 2)
			p_array.put ([3, "Winterthurerstrass", 60, 5, 2], 3)
			p_array.put ([5, "Schwamendingerplatz", 80, 5, 0], 5)
			p_array.put ([7, "Josefwiese", 100, 9, 8], 7)
			p_array.put ([8, "Escher-Wyss-Platz", 120, 9, 7], 8)
			p_array.put ([10, "Langstrasse", 160, 15, 0], 10)
			p_array.put ([12, "Schaffhauserplaz", 220, 20, 0], 12)
			p_array.put ([14, "Universitätstrasse", 260, 25, 15], 14)
			p_array.put ([15, "Irchelpark", 260, 25, 14], 15)
			p_array.put ([17, "Bellevue", 320, 37, 18], 17)
			p_array.put ([18, "Niederdorf", 350, 40, 17], 18)
			p_array.put ([20, "Bahnhofstrasse", 400, 60, 0], 20)
			create Result.make_from_array (p_array)
		end

end
