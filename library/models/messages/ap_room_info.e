note
	description: "Information about the room."
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

class
	AP_ROOM_INFO

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
		do
			make_message(a_message)
			fill_games(a_message)
			has_password := False
			hint_cost := 0
			location_check_points := 0
			if attached {JSON_BOOLEAN} a_message.item ("password") as la_password then
				has_password := la_password.item
			end
			if attached {JSON_NUMBER} a_message.item ("hint_cost") as la_hint_cost then
				hint_cost := la_hint_cost.integer_64_item.to_integer
			end
			if attached {JSON_NUMBER} a_message.item ("location_check_points") as la_location_check_points then
				location_check_points := la_location_check_points.integer_64_item.to_integer
			end
			if attached {JSON_STRING} a_message.item ("seed_name") as la_seed then
				seed := la_seed.item
			else
				seed := ""
			end
			if attached {JSON_NUMBER} a_message.item ("time") as la_time then
				initalise_time(la_time.double_item)
			else
				create time.make_now_utc
			end
			if attached {JSON_OBJECT} a_message.item ("version") as la_version then
				create version.make_with_json(la_version)
			else
				create version.make(0,0,0)
			end
			if attached {JSON_OBJECT} a_message.item ("generator_version") as la_version then
				create generator_version.make_with_json(la_version)
			else
				create generator_version.make(0,0,0)
			end
			initialise_tags(a_message)
			initialise_permissions(a_message)
		end

	initialise_permissions(a_message:JSON_OBJECT)
			-- Initialisation of the `*_permission' attributes with the data of `a_message'
		do
			if attached {JSON_OBJECT} a_message.item ("permissions") as la_permissions then
				if attached {JSON_NUMBER} la_permissions.item ("release") as la_release then
					create release_permission.make (la_release.integer_64_item)
				end
				if attached {JSON_NUMBER} la_permissions.item ("remaining") as la_remaining then
					create remaining_permission.make (la_remaining.integer_64_item)
				end
				if attached {JSON_NUMBER} la_permissions.item ("collect") as la_collect then
					create collect_permission.make (la_collect.integer_64_item)
				end
			end
		end

	initialise_tags(a_message:JSON_OBJECT)
			-- Initialisation of the `tags' attributes with the data of `a_message'
		do
			if attached {JSON_ARRAY} a_message.item ("tags") as la_tags then
				create {ARRAYED_LIST[STRING_32]}tags.make(la_tags.count)
				across la_tags as lla_tags loop
					if attached {JSON_STRING} lla_tags.item as la_item then
						tags.extend (utf_converter.utf_8_string_8_to_string_32 (la_item.item))
					end
				end
			else
				create {LINKED_LIST[STRING_32]}tags.make
			end
		end

	initalise_time(a_time:DOUBLE)
			-- Initialisation of the `time' attributes using `a_time' as internal value
		do
			create time.make_from_epoch (a_time.truncated_to_integer)
			time.time.set_fractionals (a_time-a_time.truncated_to_integer)
		end

	fill_games(a_message:JSON_OBJECT)
			-- Initialisation of the `games' attributes with the data of `a_message'
		do
			if attached {JSON_ARRAY} a_message.item ("games") as la_games then
				create {ARRAYED_LIST[AP_GAME]}games.make (la_games.count)
				across la_games as lla_games loop
					if attached {JSON_STRING} lla_games.item as la_item then
						games.extend (create {AP_GAME}.make (
								utf_converter.utf_8_string_8_to_string_32 (la_item.item)) )
					end
				end
			else
				create {ARRAYED_LIST[AP_GAME]}games.make (0)
			end
			if attached {JSON_OBJECT} a_message.item ("datapackage_versions") as la_versions then
				fill_games_version(la_versions)
			end
			if attached {JSON_OBJECT} a_message.item ("datapackage_checksums") as la_checksums then
				fill_games_checksum(la_checksums)
			end
		end

	fill_games_version(a_versions:JSON_OBJECT)
			-- Initialisation of the `games' datastore version with the data of `a_version'
		do
			across games as la_games loop
				if attached {JSON_NUMBER} a_versions.item (la_games.item.name) as la_version then
					la_games.item.set_datapackage_version (la_version.integer_64_item.to_integer)
				end
			end
		end

	fill_games_checksum(a_checksums:JSON_OBJECT)
			-- Initialisation of the `games' datastore checksum with the data of `a_checksums'
		do
			across games as la_games loop
				if attached {JSON_STRING} a_checksums.item (la_games.item.name) as la_checksums then
					la_games.item.set_datapackage_checksum (la_checksums.item)
				end
			end
		end

feature -- Access

	has_password:BOOLEAN
			-- The room need a password.

	games:LIST[AP_GAME]
			-- The games in the MultiWorld

	tags:LIST[STRING_32]
			-- The server tags

	version:AP_VERSION
			-- The Archipelago server version

	generator_version:AP_VERSION
			-- The version of the Archipelago generator

	release_permission:AP_PERMISSION
			-- Permission of the release functionnality

	remaining_permission:AP_PERMISSION
			-- Permission of the release functionnality

	collect_permission:AP_PERMISSION
			-- Permission of the collect functionnality

	hint_cost:INTEGER
			-- The cost of a hint

	location_check_points:INTEGER
			-- Point obtained by location checked.

	seed:STRING
			-- The seed of the multiworld

	time:DATE_TIME
			-- The time of the server when receiving the message

	out:STRING
			-- Text representation of `Current'
		do
			Result := out32.to_string_8
		end

	out32:STRING_32
			-- Text representation of `Current'
		do
			Result := "Room Info:%N"
			Result := Result + "%TTime: " + time.out + "%N"
			Result := Result + "%TVersion: " + version.out + "%N"
			Result := Result + "%TGenerator version: " + generator_version.out + "%N"
			Result := Result + "%TSeed: " + seed + "%N"
			Result := Result + "%TNeed password: " + has_password.out + "%N"
			Result := Result + "%THint cost: " + hint_cost.out + "%N"
			Result := Result + "%TPoints obtained at location check: " + location_check_points.out + "%N"
			Result := Result + "%TRelease permission: " + release_permission.out + "%N"
			Result := Result + "%TRemaining permission: " + remaining_permission.out + "%N"
			Result := Result + "%TCollect permission: " + collect_permission.out + "%N"
			Result := Result + "%TServer tags:%N"
			across tags as la_tags loop
				Result := Result + "%T%T"+ la_tags.item + "%N"
			end
			Result := Result + "%TServer games:%N"
			across games as la_games loop
				Result := Result + "%T%T"+ la_games.item.name + "%N"
			end
		end

feature -- Constants

	Cmd_Identifier:STRING = "RoomInfo"
			-- JSON message cmd identifier for Room Info



end
