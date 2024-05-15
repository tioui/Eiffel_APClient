note
	description: "Informations about an Archipelago game"
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

class
	AP_GAME

create
	make

feature -- Initialisation

	make(a_name:STRING_32)
			-- Initialisation of `Current' using `name' as `a_name'
		do
			name := a_name.twin
			datapackage_version := 0
			datapackage_checksum := ""
		ensure
			Name_Assign: name ~ a_name
		end

feature -- Access

	name:STRING_32
			-- How the game is named

	datapackage_version: INTEGER
			-- The version of the datapackage of `Current'

	datapackage_checksum: STRING
			-- The checksum of the datapackage of `Current'

feature {AP_ROOM_INFO} -- Setters

	set_datapackage_version(a_version:INTEGER)
			-- Assign `datapackage_version' with `a_version'
		do
			datapackage_version := a_version
		ensure
			Is_Assign: datapackage_version ~ a_version
		end

	set_datapackage_checksum(a_checksum:STRING)
			-- Assign `datapackage_checksum' with `a_checksum'
		do
			datapackage_checksum := a_checksum
		ensure
			Is_Assign: datapackage_checksum ~ a_checksum
		end
end
