class
	PROPERTY_SQUARE

inherit

	SQUARE
		redefine
			do_action,
			set_linked_property
		end

create
	make_with_tuple

feature {NONE} -- Initialization

	make_with_tuple (t: TUPLE [position: INTEGER; name: STRING; price: INTEGER; rent: INTEGER])
			-- Initialization for `Current'.
		require
			position_in_board: t.position >= 0 and t.position <= Game.board.Square_count
			name_exist: t.name /= Void and then not t.name.is_empty
			price_correct: t.price > 0
			rent_correct: t.rent > 0
		local
			i: INTEGER
		do
			name := t.name
			price := t.price
			rent := t.rent
			position := t.position
			house_price := ((position - 1) // 5 + 1) * 100
			create houses.make (0)
			from
				i := 1
			until
				i > 5
			loop
				houses.put (create {HOUSE}.make_with_square (Current, i))
				i := i + 1
			end
			create_owner_color_bar
		ensure
			name_set: name = t.name
			price_set: price = t.price
			rent_set: rent = t.rent
			position_set: position = t.position
			house_price_set: house_price > 0
		end

feature -- Access

	owner: PLAYER
			-- Owner of the property

	name: STRING
			-- Name of the property

	price: INTEGER
			-- Price of the property

	rent: INTEGER
			-- Rent price of the property

	houses: ARRAYED_SET [HOUSE]
			-- Houses of the property

	house_count: INTEGER
			-- Number of house of the property

	house_price: INTEGER
			-- Price of one house

	linked_square: like Current
			-- Other property with the same color

feature -- Basic operatin

	do_action (p: PLAYER)
			-- Applies the specific action of the square to the player `p'
		local
			rent_with_houses: INTEGER
		do
			Monopoly_view.print_text ("You are at " + name)
			if owner = Void then
				if p.money >= price then
					if Monopoly_view.confirm ("This property costs " + price.out + " CHF. Do you want to buy it ?") then
						p.add_money (- price)
						set_owner (p)
						Monopoly_view.break ("You now own " + name)
					else
						sell_to_best_bidder
					end
				else
					Monopoly_view.print_text ("You don't have enough money to buy this property")
					sell_to_best_bidder
				end
			elseif owner /= p then
				rent_with_houses := (rent * 2.5 ^ house_count).truncated_to_integer
				Monopoly_view.break ("You must pay " + rent_with_houses.out + " CHF to " + owner.name)
				p.pay_to_player (rent_with_houses, owner)
			end
		end

	set_linked_property (p: like Current)
			-- Set `p' as the linked property
		do
			linked_square := p
		ensure then
			linked_square = p
		end

	set_owner (p: PLAYER)
			-- Set `p' as owner of this property
		require
			p /= Void
		do
			owner := p
			p.add_property (Current)
			from
				houses.start
			until
				houses.after
			loop
				houses.item.view.set_background_color (p.token.color)
				houses.forth
			end
			owner_color_bar.set_background_color (p.token.color)
			if not Monopoly_view.board_view.has (owner_color_bar) then
				Monopoly_view.board_view.extend (owner_color_bar)
			end
		ensure
			owner = p
			p.properties.has (Current)
		end

	add_house (n: INTEGER)
			-- Add `n' houses to the property
		require
			n > 0
			owner: owner /= Void
			house_count < 5
			n + house_count <= 5
		local
			i: INTEGER
			limit: INTEGER
		do
			from
				i := house_count + 1
				limit := house_count
			until
				i > limit + n
			loop
				houses.go_i_th (i)
				houses.item.show
				house_count := house_count + 1
				i := i + 1
			end
			owner.add_money (- n * house_price)
		ensure
			house_count = old house_count + n
		end

	sell_house (n: INTEGER)
			-- Remove `n' houses from the property
		require
			n > 0
			owner: owner /= Void
			house_exist: house_count >= 1
			house_count - n >= 0
		local
			i: INTEGER
			limit: INTEGER
		do
			from
				i := house_count
				limit := house_count
			until
				i = limit - n
			loop
				houses.go_i_th (i)
				houses.item.hide
				house_count := house_count - 1
				i := i - 1
			end
			owner.add_money (n * (house_price * 0.7).truncated_to_integer)
		ensure
			house_count = old house_count - n
		end

	sell_to_best_bidder
			-- Sells the property to the best bidder
		local
			bid_result: TUPLE [player: PLAYER; price: INTEGER]
		do
			bid_result := bid
			if bid_result /= Void and bid_result.player /= Void then
				if owner = Void then
					bid_result.player.add_money (- bid_result.price)
				else
					bid_result.player.pay_to_player (bid_result.price, owner)
				end
				set_owner (bid_result.player)
				Monopoly_view.break (bid_result.player.name + " bought " + name + " for " + bid_result.price.out + " CHF")
			end
		end

	bid: TUPLE [player: PLAYER; price: INTEGER]
			-- Let the players bid to buy this property
		local
			modal: BID_DIALOG
		do
			create modal
			modal.set_title ("Who buys " + name + " ?")
			modal.show_modal_to_window (Monopoly_view.main_window)
			if modal.selected_button /= Void and then modal.selected_button ~ (create {EV_DIALOG_CONSTANTS}).ev_ok then
				Result := [modal.selected_player, modal.price.value]
			end
		end

	remove_owner
			-- Removes the owner of the property
		do
			if house_count /= 0 then
				sell_house (house_count)
			end
			if owner_color_bar /= Void and then Monopoly_view.board_view.has (owner_color_bar) then
				Monopoly_view.board_view.prune_all (owner_color_bar)
			end
			owner := get_void_owner
		ensure
			owner = Void
		end

feature {NONE} -- Graphical implementation

	create_house: EV_MODEL_POLYGON
			-- Return a model for one house
		local
			coord: ARRAY [EV_COORDINATE]
		do
			create coord.make_empty
			coord.force (create {EV_COORDINATE}.make (-7, 0), 1)
			coord.force (create {EV_COORDINATE}.make (7, 0), 2)
			coord.force (create {EV_COORDINATE}.make (0, 10), 3)
			create Result.make_with_coordinates (coord)
		end

	owner_color_bar: EV_MODEL_RECTANGLE
			-- Bar showing at the bottom of the property when a player owns it

	create_owner_color_bar
			-- Initializes the owner color bar
		require
			owner_color_bar = Void
		local
			square_position: INTEGER
		do
			square_position := get_square_position
			if (position - 1) // 5 = 0 then
				create owner_color_bar.make_with_positions (Board_width - square_position, Board_width - 5, Board_width - (square_position + Square_width.truncated_to_integer), Board_width)
			elseif (position - 1) // 5 = 2 then
				create owner_color_bar.make_with_positions (square_position, 0, square_position + Square_width.truncated_to_integer, 5)
			elseif (position - 1) // 5 = 1 then
				create owner_color_bar.make_with_positions (0, Board_width - square_position, 5, Board_width - (square_position + Square_width.truncated_to_integer))
			elseif (position - 1) // 5 = 3 then
				create owner_color_bar.make_with_positions (Board_width - 5, square_position, Board_width, square_position + Square_width.truncated_to_integer)
			end
		ensure
			owner_color_bar /= Void
		end

	get_square_position: INTEGER
			-- Get the coordinate of the square at position `position'
		do
			Result := Square_height + ((position - ((position - 1) // 5 * 5) - 2) * Square_width).truncated_to_integer
		ensure
			Result >= 0 and Result <= Board_width
		end

	get_void_owner: PLAYER
			-- Return a void owner
			-- This function is needed for Void safety mode compatibility
		do
		ensure
			Result = Void
		end

invariant
	correct_houses_count: house_count >= 0 and house_count <= 5

end
