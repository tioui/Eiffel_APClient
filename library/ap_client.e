note
	description: "A client for Archipelago connection"
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

class
	AP_CLIENT

inherit
	THREAD
		rename
			make as make_thread
		end

create
	make,
	make_with_certificate_store,
	make_with_uuid,
	make_with_uuid_and_certificate_store

feature {NONE}

	make_with_uuid_and_certificate_store (a_game, a_server, a_uuid, a_certificate_store: STRING)
			-- Initialisation of `Current' using `a_game' as `game', `a_uuid' as `uuid'
			-- `a_server' as server URI and `a_certificate_store' as certificate file.
		do
			make_with_uuid (a_game, a_server, a_uuid)
			socket_client.set_secure_certificate_file (create {PATH}.make_from_string (a_certificate_store))
		end

	make_with_uuid (a_game, a_server, a_uuid: STRING)
			-- Initialisation of `Current' using `a_game' as `game', `a_uuid' as `uuid'
			-- `a_server' as server URI.
		do
			make_thread
			create json_serializer
			json_serializer.register (create {AP_SLOT_CONNECT_SERIALIZER}, {detachable AP_SLOT_CONNECT})
			json_serializer.register (create {AP_VERSION_SERIALIZER}, {detachable AP_VERSION})
			game := a_game.twin
			uuid := a_uuid.twin
			create room_info_actions
			create connected_actions
			create socket_client.make (a_server)
			socket_client.text_message_actions.extend (agent on_text_message)
		ensure
			game_assign: game ~ a_game
			uuid_assign: uuid ~ a_uuid
			server_valid: socket_client.Server ~ a_server.to_string_8
		end

	make_with_certificate_store (a_game, a_server, a_certificate_store: STRING)
			-- Initialisation of `Current' using `a_game' as `game',
			-- `a_server' as server URI and `a_certificate_store' as certificate file.
		do
			make_with_uuid_and_certificate_store (a_game, a_server, generate_uuid, a_certificate_store)
		end

	make (a_game, a_server: STRING)
			-- Initialisation of `Current' using `a_game' as `game' and `a_server' as server URI.
		do
			make_with_uuid (a_game, a_server, generate_uuid)
		end

feature

	game: STRING
			-- The name of the game client.

	uuid: STRING
			-- The unique ID of this execution.

	has_room_info: BOOLEAN
			-- The Room info has been loaded (after the call to `connect').
		do
			Result := attached internal_room_info
		end

	room_info: AP_ROOM_INFO
			-- The room information (after the call to `connect').
		require
			has_room_info: has_room_info
		do
			check
					attached internal_room_info as la_room_info
			then
				Result := la_room_info
			end
		end

feature

	room_info_actions: ACTION_SEQUENCE [TUPLE[room_info:AP_ROOM_INFO]]
			-- Actions to launch when the room_info message has been received

	connected_actions: ACTION_SEQUENCE
			-- Actions to launch when the socket has been connected.

	disconnected_actions: ACTION_SEQUENCE [TUPLE[code:INTEGER; reason:STRING]]
			-- Actions to launch when the socket has been disconnected.
		do
			Result := socket_client.close_actions
		end

	error_actions: ACTION_SEQUENCE [TUPLE[message:STRING]]
			-- Actions to launch when there has been an error
		do
			Result := socket_client.error_actions
		end

feature

	generate_uuid: STRING
			-- Generate an unique ID
		do
			Result := {UUID_GENERATOR}.generate_uuid.out
		end

	connect
			-- Start the web socket event system.
			-- Create another thread.
		do
			launch
		end

	execute
			-- Start the web socket event system.
			-- No not create another thread.
		do
			socket_client.execute
		end

	connect_slot (a_player_name, a_password: STRING; a_tags: LIST [STRING]; a_item_flags: AP_ITEM_MANAGEMENT; a_version: AP_VERSION)
			-- Connect to a player slot using `a_player_name' as slot name, `a_password' as slot password,
			-- `a_tags' as slot tags, `a_item_flags' as item management flags and `a_version' as Archipelago
			-- server version compatibility.
		local
			l_connect: AP_SLOT_CONNECT
		do
			create l_connect.make (game, uuid, a_player_name, a_password, a_version, a_item_flags, a_tags)
			send_message (l_connect)
		end

feature {NONE}

	send_messages (a_messages: FINITE [AP_MESSAGE_TO_SEND])
			-- Send a list of messages (`a_messages') to the server.
		local
			l_json_list: JSON_ARRAY
		do
			create l_json_list.make (a_messages.count)
			across
				a_messages as la_messages
			loop
				l_json_list.extend (json_serializer.to_json (la_messages.item))
			end
			socket_client.send (l_json_list.representation)
		end

	send_message (a_message: AP_MESSAGE_TO_SEND)
			-- Send `a_messages' to the server.
		do
			send_messages (<<a_message>>)
		end

	json_serializer: JSON_SERIALIZATION
			-- Used to serialize {AP_MESSAGE_TO_SEND} message to json.

	internal_room_info: detachable AP_ROOM_INFO
			-- Internal version of `room_info.

	on_text_message (a_message: STRING)
			-- Launch when a text message is received from the server.
		local
			l_json_parser: JSON_PARSER
		do
			create l_json_parser.make_with_string (a_message)
			l_json_parser.parse_content
			if attached l_json_parser.parsed_json_array as la_array then
				across
					la_array as lla_array
				loop
					if attached {JSON_OBJECT} lla_array.item as la_object then
						parse_individual_message (la_object)
					end
				end
			end
		end

	parse_individual_message (a_message: JSON_OBJECT)
			-- Parse json `a_message' object to an {AP_MESSAGE_RECEIVED}
		local
			l_cmd: STRING
			l_room_info: AP_ROOM_INFO
		do
			l_cmd := {AP_MESSAGE_INFO}.cmd_message (a_message)
			if l_cmd ~ {AP_ROOM_INFO}.cmd_identifier then
				create l_room_info.make (a_message)
				internal_room_info := l_room_info
				room_info_actions.call (l_room_info)
			end
		end

	on_open (a_message: STRING)
			-- Launch when a web socket has been opened.
		do
			connected_actions.call
		end

	socket_client: AP_WEB_SOCKET_CLIENT
			-- The websocket client

end

