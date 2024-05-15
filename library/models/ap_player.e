note
	description: "Represent a player"
	author: "Louis M"
	date: "Tue, 14 May 2024 16:51:25 +0000"
	revision: "0.1"

class
	AP_PLAYER

inherit
	ANY
		redefine
			out
		end

create
	make,
	make_with_json

feature {NONE} -- Initialisation

	make(a_team, a_slot:INTEGER; a_name, a_alias:READABLE_STRING_GENERAL)
			-- Initialisation of `Current' using `a_team' as `team', `a_slot' as `slot',
			-- `a_name' as `name' and `a_alias' as `alias_name'.
		do
			team := a_team
			slot := a_slot
			name := a_name
			alias_name := a_alias
		ensure
			Is_Team_Assign: team ~ a_team
			Is_Slot_Assign: slot ~ a_slot
			Is_Name_Assign: name ~ a_name
			Is_Alias_Name_Assign: alias_name ~ a_alias
		end

	make_with_json(a_json:JSON_OBJECT)
			-- Initialisation of `Current' using `a_json' to assign `major', `minor' and `build'
		require
			Is_Version: attached {JSON_STRING} a_json.item ("class") as la_item and then la_item.item ~ "NetworkPlayer"
		local
			l_team:INTEGER
			l_slot:INTEGER
			l_name:STRING
			l_alias:STRING
			l_converter:UTF_CONVERTER
		do
			if attached {JSON_NUMBER} a_json.item ("team") as la_team then
				l_team := la_team.integer_64_item.to_integer
			end
			if attached {JSON_NUMBER} a_json.item ("slot") as la_slot then
				l_slot := la_slot.integer_64_item.to_integer
			end
			if attached {JSON_STRING} a_json.item ("name") as la_name then
				l_name := l_converter.utf_8_string_8_to_escaped_string_32 (la_name.item)
			else
				l_name := ""
			end
			if attached {JSON_STRING} a_json.item ("alias") as la_alias then
				l_alias := l_converter.utf_8_string_8_to_escaped_string_32 (la_alias.item)
			else
				l_alias := l_name
			end
			make(l_team, l_slot, l_name, l_alias)
		end

feature -- Access

	team:INTEGER
			-- The team number of `Current'

	slot:INTEGER
			-- The slot number of `Current' in the `team'

	name:READABLE_STRING_GENERAL
			-- The identifier of `Current'

	alias_name:READABLE_STRING_GENERAL
			-- The alias of `Current'

	out:STRING
			-- Text representation of `Current'
		do
			Result := out32.to_string_8
		end

	out32:STRING_32
			-- Text representation of `Current'
		do
			Result := "Player:%N"
			Result := Result + "team = " + team.out + "%N"
			Result := Result + "slot = " + slot.out + "%N"
			Result := Result + "name = " + name.to_string_32 + "%N"
			Result := Result + "alias_name = " + alias_name.to_string_32
		end

end
