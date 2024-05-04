note
	description: "Summary description for {AP_CLIENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

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
		do
			make_with_uuid (a_game, a_server, a_uuid)
			socket_client.set_secure_certificate_file (create {PATH}.make_from_string (a_certificate_store))
		end

	make_with_uuid (a_game, a_server, a_uuid: STRING)
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
		do
			make_with_uuid_and_certificate_store (a_game, a_server, generate_uuid, a_certificate_store)
		end

	make (a_game, a_server: STRING)
		do
			make_with_uuid (a_game, a_server, generate_uuid)
		end

feature

	game: STRING

	uuid: STRING

	has_room_info: BOOLEAN
		do
			Result := attached internal_room_info
		end

	room_info: AP_ROOM_INFO
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

	connected_actions: ACTION_SEQUENCE

	disconnected_actions: ACTION_SEQUENCE [TUPLE[code:INTEGER; reason:STRING]]
		do
			Result := socket_client.close_actions
		end

	error_actions: ACTION_SEQUENCE [TUPLE[message:STRING]]
		do
			Result := socket_client.error_actions
		end

feature

	generate_uuid: STRING
		do
			Result := {UUID_GENERATOR}.generate_uuid.out
		end

	connect
		do
			launch
		end

	connect_slot (a_player_name, a_password: STRING; a_tags: LIST [STRING]; a_flags: AP_SLOT_FLAG; a_version: AP_VERSION)
		local
			l_connect: AP_SLOT_CONNECT
		do
			create l_connect.make (game, uuid, a_player_name, a_password, a_version, a_flags, a_tags)
			send_message (l_connect)
		end

feature {NONE}

	execute
		do
			socket_client.execute
		end

	send_messages (a_messages: FINITE [AP_MESSAGE_TO_SEND])
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
		do
			send_messages (<<a_message>>)
		end

	json_serializer: JSON_SERIALIZATION

	internal_room_info: detachable AP_ROOM_INFO

	on_text_message (a_message: STRING)
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
		do
			connected_actions.call
		end

	socket_client: AP_WEB_SOCKET_CLIENT

end

