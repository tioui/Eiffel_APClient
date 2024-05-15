note
	description: "Summary description for {AP_SLOT_CONNECTION_INFO}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	AP_SLOT_CONNECTION_INFO

inherit
	AP_MESSAGE_RECEIVED
		rename
			make as make_message
		redefine
			out
		end

create
	make

feature {NONE} -- Initialisation

	make(a_message:JSON_OBJECT)
			-- Initialisation of `Current' using `a_message' to load informations.
		require
			Is_Room_Info: {AP_MESSAGE_INFO}.cmd_message(a_message) ~ Cmd_Identifier
		local
			l_team:INTEGER
			l_slot:INTEGER
			l_player_found:BOOLEAN
		do
			make_message(a_message)
			if attached {JSON_NUMBER} a_message.item ("team") as la_team then
				l_team := la_team.integer_64_item.to_integer
			end
			if attached {JSON_NUMBER} a_message.item ("slot") as la_slot then
				l_slot := la_slot.integer_64_item.to_integer
			end
			if attached {JSON_ARRAY} a_message.item ("players") as la_players then
				initialize_players(la_players)
			else
				create {LINKED_LIST[AP_PLAYER]}players.make
			end
			create player.make (0, 0, "", "")
			from
				players.start
				l_player_found := False
			until
				players.exhausted or l_player_found
			loop
				if players.item.slot ~ l_slot and players.item.team ~ l_team then
					player := players.item
					l_player_found := True
				end
			end
			if attached {JSON_ARRAY} a_message.item ("missing_locations") as la_locations then
				create {ARRAYED_LIST[INTEGER]}missing_locations.make(la_locations.count)
				fill_locations(la_locations, missing_locations)
			else
				create {LINKED_LIST[INTEGER]}missing_locations.make
			end
			if attached {JSON_ARRAY} a_message.item ("missing_locations") as la_locations then
				create {ARRAYED_LIST[INTEGER]}checked_locations.make(la_locations.count)
				fill_locations(la_locations, checked_locations)
			else
				create {LINKED_LIST[INTEGER]}checked_locations.make
			end
			if attached {JSON_OBJECT} a_message.item ("slot_info") as la_slot_info then
				create slots.make (la_slot_info.count)
				fill_slot_info(la_slot_info, slots)
			else
				create slots.make (0)
			end
			if attached {JSON_NUMBER} a_message.item ("hint_points") as la_hint_points then
				hint_points := la_hint_points.integer_64_item.to_integer
			end
			if attached {JSON_OBJECT} a_message.item ("slot_data") as la_slot_data then
				slot_data := la_slot_data
			else
				slot_data := create {JSON_OBJECT}.make_empty
			end
		end

	initialize_players(a_message:JSON_ARRAY)
			-- Initialize `players' with the data of `a_message'
		do
			create {ARRAYED_LIST[AP_PLAYER]}players.make(a_message.count)
			across a_message as la_players loop
				if attached {JSON_OBJECT} la_players.item as la_player then
					players.extend(create {AP_PLAYER}.make_with_json (la_player))
				end
			end
		end

	fill_locations(a_message:JSON_ARRAY; a_locations:LIST[INTEGER])
			-- Fill `a_locations' with the values in `a_message'
		do
			across a_message as la_locations loop
				if attached {JSON_NUMBER} la_locations.item as la_location then
					a_locations.extend (la_location.integer_64_item.to_integer)
				end
			end
		end

	fill_slot_info(a_message:JSON_OBJECT; a_slots:HASH_TABLE[AP_SLOT_INFO, INTEGER])
		do
			across a_message as la_objects loop
				if la_objects.key.item.is_integer and attached {JSON_OBJECT} la_objects.item as la_slot_info then
					a_slots.extend (create {AP_SLOT_INFO}.make_with_json(la_slot_info), la_objects.key.item.to_integer)
				end
			end
		end

--"slot_data":{"ingredientReplacement":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75],"aquarianTranslate":false,"secret_needed":false,"minibosses_to_kill":0,"bigbosses_to_kill":0,"skip_first_vision":false,"unconfine_home_water_energy_door":false,"unconfine_home_water_transturtle":false}}

feature -- Access

	player:AP_PLAYER
			-- The current player using this client.

	players:LIST[AP_PLAYER]
			-- Every players playing in the multiworld

	missing_locations:LIST[INTEGER]
			-- Locations that is not found yet

	checked_locations:LIST[INTEGER]
			-- Locations that has been found

	slots:HASH_TABLE[AP_SLOT_INFO, INTEGER]
		-- Information about every slot in the room.

	hint_points:INTEGER
			-- The number of points needed to get a hint.

	slot_data:JSON_OBJECT
			-- Every data send from the APWorld to the client

	out:STRING
			-- Text representation of `Current'
		do
			Result:= out32.to_string_8
		end

	out32:STRING
			-- Text representation of `Current'
		local
			l_is_first:BOOLEAN
		do
			Result := "Slot connected:%N"
			Result := Result + player.out32 + "%N"
			Result := Result + "Hint points: " + hint_points.out + "%N"
			Result := Result + "Players:%N"
			across players as la_players loop
				Result := Result + la_players.item.out32 + "%N"
			end
			Result := Result + "Slots:%N"
			across slots as la_slots loop
				Result := Result + la_slots.key.out + ": " + la_slots.item.out32 + "%N"
			end
			l_is_first := True
			Result := Result + "Checked locations:"
			across checked_locations as la_checked_locations loop
				if l_is_first then
					Result := Result + la_checked_locations.item.out
					l_is_first := False
				end
				Result := Result + ", " + la_checked_locations.item.out
			end
			l_is_first := True
			Result := Result + "%NMissing locations:"
			across missing_locations as la_missing_locations loop
				if l_is_first then
					Result := Result + la_missing_locations.item.out
					l_is_first := False
				end
				Result := Result + ", " + la_missing_locations.item.out
			end
			Result := Result + "%NSlot data: " + slot_data.representation
		end


feature -- Constants

	Cmd_Identifier:STRING = "Connected"
			-- JSON message cmd identifier for Room Info
end
