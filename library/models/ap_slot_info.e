note
	description: "Summary description for {AP_SLOT_INFO}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	AP_SLOT_INFO

inherit
	ANY
		redefine
			out
		end

create
	make,
	make_with_json

feature {NONE} -- Initialisation

	make(a_name, a_game:READABLE_STRING_GENERAL; a_internal_type:INTEGER; a_group_members:LIST[INTEGER])
			-- Initialisation of `Current' using `a_team' as `team', `a_slot' as `slot',
			-- `a_name' as `name' and `a_alias' as `alias_name'.
		do
			name := a_name
			game := a_game
			internal_type := a_internal_type
			group_members := a_group_members
		ensure
			Is_Name_Assign: name ~ a_name
			Is_Game_Assign: game ~ a_game
			Is_Type_Assign: internal_type ~ a_internal_type
		end

	make_with_json(a_json:JSON_OBJECT)
			-- Initialisation of `Current' using `a_json' to assign `major', `minor' and `build'
		require
			Is_Version: attached {JSON_STRING} a_json.item ("class") as la_item and then la_item.item ~ "NetworkPlayer"
		local
			l_internal_type:INTEGER
			l_name:STRING
			l_game:STRING
			l_group_members:LIST[INTEGER]
			l_converter:UTF_CONVERTER
		do
			if attached {JSON_NUMBER} a_json.item ("type") as la_internal_type then
				l_internal_type := la_internal_type.integer_64_item.to_integer
			end
			if attached {JSON_STRING} a_json.item ("name") as la_name then
				l_name := l_converter.utf_8_string_8_to_escaped_string_32 (la_name.item)
			else
				l_name := ""
			end
			if attached {JSON_STRING} a_json.item ("game") as la_game then
				l_game := l_converter.utf_8_string_8_to_escaped_string_32 (la_game.item)
			else
				l_game := ""
			end
			if attached {JSON_ARRAY} a_json.item ("group_members") as la_group_members then
				create {ARRAYED_LIST[INTEGER]}l_group_members.make (la_group_members.count)
				across la_group_members as la_members loop
					if attached {JSON_NUMBER} la_members.item as la_member then
						l_group_members.extend (la_member.integer_64_item.to_integer)
					end
				end
			else
				create {LINKED_LIST[INTEGER]}l_group_members.make
			end
			make(l_name, l_game, l_internal_type, l_group_members)
		end

feature -- Access

	name:READABLE_STRING_GENERAL
			-- The identifier of `Current'

	game:READABLE_STRING_GENERAL
			-- The name of the game that the current player is playing.

	group_members:LIST[INTEGER]
			-- Every members in the group (only when `is_group')

	is_spectator:BOOLEAN
			-- The slot is a spectator
		do
			Result := internal_type ~ 0
		end

	is_player:BOOLEAN
			-- The slot is a player
		do
			Result := internal_type ~ 1
		end

	is_group:BOOLEAN
			-- The slot is a group of players
		do
			Result := internal_type ~ 2
		end


	out:STRING
			-- Text representation of `Current'
		do
			Result := out32.to_string_8
		end

	out32:STRING_32
			-- Text representation of `Current'
		do
			Result := "Slot:%N"
			Result := Result + "name = " + name.to_string_32 + "%N"
			Result := Result + "game = " + game.to_string_32 + "%N"
			if is_spectator then
				Result := Result + "Is a spectator%N"
			elseif is_player then
				Result := Result + "Is a player%N"
			elseif is_group then
				Result := Result + "Is a group containing players:%N"
				across group_members as la_group loop
					Result := Result + "ID = " + la_group.item.out + "%N"
				end
			end
		end

feature {NONE} -- Implementation

	internal_type:INTEGER

invariant
	Type_Valid: internal_type >= 0 and internal_type <= 2
end
