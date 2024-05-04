note
	description: "Summary description for {AP_GAME}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	AP_GAME

create
	make

feature -- Initialisation

	make(a_name:STRING)
		do
			name := a_name.twin
			datapackage_version := 0
			datapackage_checksum := ""
		ensure
			Name_Assign: name ~ a_name
		end

feature -- Access

	name:STRING

	datapackage_version: INTEGER

	datapackage_checksum: STRING

feature {AP_ROOM_INFO} -- Setters

	set_datapackage_version(a_version:INTEGER)
		do
			datapackage_version := a_version
		ensure
			Is_Assign: datapackage_version ~ a_version
		end

	set_datapackage_checksum(a_checksum:STRING)
		do
			datapackage_checksum := a_checksum
		ensure
			Is_Assign: datapackage_checksum ~ a_checksum
		end
end
