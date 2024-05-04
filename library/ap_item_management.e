note
	description: "Flags used to know what kind of item the client manage."
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

class
	AP_ITEM_MANAGEMENT

create
	make_no_item_handeling,
	make_item_from_others,
	make_item_from_others_and_self,
	make_item_from_others_and_receiving_starting,
	make_full_item_handeling,
	make_with_value

feature {NONE} -- Initialisation

	make_no_item_handeling
			-- No ReceivedItems is sent to you, ever.
		do
			disable_item_from_others
		ensure
			No_Item_Handeling: not is_item_from_others_enabled and
			                   not is_item_from_self_enabled and
			                   not is_receiving_starting_items_enabled
		end

	make_item_from_others
			-- Indicates you get items sent from other worlds.
		do
			enable_item_from_others
		ensure
			Is_Item_From_Others_Enable: is_item_from_others_enabled
		end

	make_item_from_others_and_self
			-- Indicates you get items sent from your own world and from other world.
		do
			enable_item_from_self
		ensure
			Is_Item_From_Others_Enable: is_item_from_others_enabled
			Is_Item_From_Self_Enable: is_item_from_self_enabled
		end

	make_item_from_others_and_receiving_starting
			-- Indicates you get your starting inventory sent and that you
			-- will get items from other worlds.
		do
			enable_receiving_starting_items
		ensure
			Is_Item_From_Others_Enable: is_item_from_others_enabled
			Is_Receiving_Starting_Enable: is_receiving_starting_items_enabled
		end

	make_full_item_handeling
			-- Full item handling
		do
			enable_receiving_starting_items
			enable_item_from_self
		ensure
			Is_Item_From_Others_Enable: is_item_from_others_enabled
			Is_Item_From_Self_Enable: is_item_from_self_enabled
			Is_Receiving_Starting_Enable: is_receiving_starting_items_enabled
		end

	make_with_value(a_value:NATURAL_8)
			-- Initialisation of `Current' wit a manual flags
		do
			value := a_value
		ensure
			Is_Assign: value ~ a_value
		end

feature -- Transformation

	disable_item_handeling
			-- No Received Items is sent to you, ever.
		do
			value := 0
		end

	enable_item_from_others
			-- Indicates you get items sent from other worlds.
		do
			value := value.bit_or (0b001)
		end

	disable_item_from_others
			-- Indicates you will not get items sent from other worlds.
			-- Note that this will also `disable_item_from_self' and
			-- `enable_receiving_starting_items'. This is equivalent to
			-- `disable_item_handeling`
		do
			value := 0
		end

	is_item_from_others_enabled:BOOLEAN
			-- Indicates you get items sent from other worlds.
		do
			Result := value.bit_and (0b001) > 0
		end

	enable_item_from_self
			-- Indicates you get items sent from your own world.
			-- Note that this will automatically `enable_item_from_others'.
		do
			value := value.bit_or (0b011)
		end

	disable_item_from_self
			-- Indicates you will not get items sent from your own world.
		do
			value := value.bit_and (0b101)
		end

	is_item_from_self_enabled:BOOLEAN
			-- Indicates you get items sent from your own world.
		do
			Result := value.bit_and (0b010) > 0
		end

	enable_receiving_starting_items
			-- Indicates you get your starting inventory sent.
			-- Note that this will automatically `enable_item_from_others'.
		do
			value := value.bit_or (0b101)
		end

	disable_receiving_starting_items
			-- Indicates you will not get your starting inventory sent.
		do
			value := value.bit_and (0b011)
		end

	is_receiving_starting_items_enabled:BOOLEAN
			-- Indicates you get your starting inventory sent.
		do
			Result := value.bit_and (0b010) > 0
		end

	value:NATURAL_8
			-- The internal value of `Current'
end
