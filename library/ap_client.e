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

feature {NONE} -- Initialisation

	make_with_uuid_and_certificate_store (a_game:READABLE_STRING_GENERAL; a_server, a_uuid, a_certificate_store: STRING)
			-- Initialisation of `Current' using `a_game' as `game', `a_uuid' as `uuid'
			-- `a_server' as server URI and `a_certificate_store' as certificate file.
		do
			make_with_uuid (a_game, a_server, a_uuid)
			socket_client.set_secure_certificate_file (create {PATH}.make_from_string (a_certificate_store))
		end

	make_with_uuid (a_game:READABLE_STRING_GENERAL; a_server, a_uuid: STRING)
			-- Initialisation of `Current' using `a_game' as `game', `a_uuid' as `uuid'
			-- `a_server' as server URI.
		do
			make_thread
			create json_serializer
			json_serializer.register (create {AP_SLOT_CONNECT_SERIALIZER}, {detachable AP_SLOT_CONNECT_UPDATE})
			json_serializer.register (create {AP_VERSION_SERIALIZER}, {detachable AP_VERSION})
			game := a_game.twin
			uuid := a_uuid.twin
			giving_up := False
			server := a_server.twin
			create room_info_actions
			create connected_actions
			create error_actions
			create slot_connected_actions
			initialize_socket(a_server)
		ensure
			game_assign: game ~ a_game
			uuid_assign: uuid ~ a_uuid
			server_valid: socket_client.Server ~ a_server.to_string_8
		end

	make_with_certificate_store (a_game:READABLE_STRING_GENERAL; a_server, a_certificate_store: STRING)
			-- Initialisation of `Current' using `a_game' as `game',
			-- `a_server' as server URI and `a_certificate_store' as certificate file.
		do
			make_with_uuid_and_certificate_store (a_game, a_server, generate_uuid, a_certificate_store)
		end

	make (a_game:READABLE_STRING_GENERAL; a_server: STRING)
			-- Initialisation of `Current' using `a_game' as `game' and `a_server' as server URI.
		do
			make_with_uuid (a_game, a_server, generate_uuid)
		end

	initialize_socket(a_server:STRING)
			-- Initialize the `socket_client'
		do
			create socket_client.make (a_server)
			socket_client.text_message_actions.extend (agent on_text_message)
			socket_client.error_actions.extend (agent on_error)
		end

feature -- Access

	game: READABLE_STRING_GENERAL;
			-- The name of the game client.

	uuid: STRING
			-- The unique ID of this execution.

	server:STRING
			-- The address used to connect to the server

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

	has_slots_info: BOOLEAN
			-- The Slots info has been loaded (after the call to `connect_slot').
		do
			Result := attached internal_slots_info
		end

	slots_info: AP_SLOT_CONNECTION_INFO
			-- The slots information (after the call to `connect_slot').
		require
			Has_Slots_Info: has_slots_info
		do
			check
					attached internal_slots_info as la_slots_info
			then
				Result := la_slots_info
			end
		end

feature	-- Events

	slot_connected_actions:ACTION_SEQUENCE [TUPLE[slot_connection_info:AP_SLOT_CONNECTION_INFO]]

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

	has_error:BOOLEAN
			-- An error occured at connection

feature -- Basic operations

	generate_uuid: STRING
			-- Generate an unique ID
		do
			Result := {UUID_GENERATOR}.generate_uuid.out
		ensure
			class
		end

	connect
			-- Start the web socket event system.
			-- Create another thread.
		do
			launch
			from
			until
				is_connected or giving_up
			loop
				yield
			end
		end

	execute
			-- Start the web socket event system.
			-- No not create another thread.
		do
			socket_client.execute
			if not is_connected and not server.starts_with ("ws://") and
					not server.starts_with ("wss://") then
				initialize_socket("ws://" + server)
				socket_client.execute
				giving_up := True
			end
		end

	close
		do
			socket_client.close (0)
			join
		end

	is_connected:BOOLEAN
			-- The web socket is connected
		do
			Result := socket_client.is_connected
		end

	connect_slot (a_player_name, a_password: STRING; a_tags: LIST [STRING]; a_item_flags: AP_ITEM_MANAGEMENT; a_version: AP_VERSION)
			-- Connect to a player slot using `a_player_name' as slot name, `a_password' as slot password,
			-- `a_tags' as slot tags, `a_item_flags' as item management flags and `a_version' as Archipelago
			-- server version compatibility.
		local
			l_connect: AP_SLOT_CONNECT
			l_converter:UTF_CONVERTER
			l_game:STRING
		do
			if game.is_string_32 then
				l_game := l_converter.utf_32_string_to_utf_8_string_8 (game.to_string_32)
			else
				l_game := game.to_string_8
			end
			create l_connect.make (l_game, uuid, a_player_name, a_password, a_version, a_item_flags, a_tags)
			send_message (l_connect)
		end

	update_slot (a_tags: LIST [STRING]; a_item_flags: AP_ITEM_MANAGEMENT)
			-- Update the player slot using `a_tags' as slot tags and `a_item_flags'
			-- as item management flags
		local
			l_connect: AP_SLOT_CONNECT_UPDATE
		do
			create l_connect.make (a_item_flags, a_tags)
			send_message (l_connect)
		end


feature {NONE} -- Implementation

	giving_up:BOOLEAN
			-- True if the connection seems impossible

	on_error(a_message:STRING)
			-- When the `socket_client' send a message.
		do
			has_error := True
			error_actions.call (a_message)
		end

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

	internal_slots_info: detachable AP_SLOT_CONNECTION_INFO
			-- Internal version of `slots_info.

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
			l_slot_connected: AP_SLOT_CONNECTION_INFO
		do
			--print("Message: " + a_message.representation + "%N")
			l_cmd := {AP_MESSAGE_INFO}.cmd_message (a_message)
			if l_cmd ~ {AP_ROOM_INFO}.cmd_identifier then
				create l_room_info.make (a_message)
				internal_room_info := l_room_info
				room_info_actions.call (l_room_info)
			elseif l_cmd ~ {AP_SLOT_CONNECTION_INFO}.cmd_identifier then
				create l_slot_connected.make(a_message)
				internal_slots_info := l_slot_connected
				slot_connected_actions.call (l_slot_connected)
			end
		end

	on_open (a_message: STRING)
			-- Launch when a web socket has been opened.
		do
			connected_actions.call
		end

	socket_client: AP_WEB_SOCKET_CLIENT
			-- The websocket client



--Message: {"cmd":"PrintJSON","data":[{"text":"Louis (Team #1) playing Aquaria has joined. Client(0.4.6), ['DebugClient']."}],"type":"Join","team":0,"slot":1,"tags":["DebugClient"]}
--Message: {"cmd":"PrintJSON","data":[{"text":"Now that you are connected, you can use !help to list commands to run via the server. If your client supports it, you may have additional local commands you can list with /help."}],"type":"Tutorial"}

end

