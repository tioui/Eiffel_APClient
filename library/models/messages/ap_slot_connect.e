note
	description: "Message of slot connection to send"
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

class
	AP_SLOT_CONNECT

inherit
	AP_SLOT_CONNECT_UPDATE
		rename
			make as make_update
		redefine
			Cmd_identifier
		end

create
	make

feature {NONE} -- Initialisation

	make(a_game, a_uuid, a_name, a_password:STRING; a_version: AP_VERSION;
			a_items_handling: AP_ITEM_MANAGEMENT; a_tags:LIST[STRING])
		do
			make_update(a_items_handling, a_tags)
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

feature -- Constants

	Cmd_Identifier:STRING = "Connect"
			-- JSON message cmd identifier for a Slot connection
end
