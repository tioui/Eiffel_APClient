note
	description: "Summary description for {AP_SLOT_CONNECT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	AP_SLOT_CONNECT

inherit
	AP_MESSAGE_TO_SEND

create
	make

feature {NONE} -- Initialisation

	make(a_game, a_uuid, a_name, a_password:STRING; a_version: AP_VERSION;
			a_items_handling: AP_SLOT_FLAG; a_tags:LIST[STRING])
		do
			default_create
			game := a_game.twin
			uuid := a_uuid.twin
			name := a_name.twin
			password := a_password.twin
			version := a_version.twin
			items_handling := a_items_handling.value
			create {ARRAYED_LIST[STRING]}tags.make (a_tags.count)
			tags.compare_objects
			across a_tags as la_tags loop
				tags.extend(la_tags.item.twin)
			end
		ensure
			Is_Cmd_Valid: cmd ~ Cmd_identifier
			Is_game_valid: game ~ a_game
			Is_uuid_valid: uuid ~ a_uuid
			Is_name_valid: name ~ a_name
			Is_password_valid: password ~ a_password
			Is_version_valid: version ~ a_version
			Is_Items_Handling_Valid: items_handling ~ a_items_handling.value
			Is_Tags_Valid: tags ~ a_tags
		end

feature -- Access

	game: STRING
			-- The name of the game played

	uuid: STRING
			-- The uuid of the client

	name: STRING
			-- The name of the player

	password: STRING
			-- The password to connect to the slot

	version: AP_VERSION
			-- The Archipelago version compatible with the client

	items_handling: INTEGER
			-- The item handling flags

	tags: LIST[STRING]
			-- The tags of the connection slot

feature -- Constants

	Cmd_Identifier:STRING = "Connect"
			-- JSON message cmd identifier for a Slot connection
end
