note
	description: "A testing console for Archipelago client"
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

class
	APPLICATION

inherit
	ARGUMENTS_32

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			l_command:STRING
		do
			create apclient.make ("Aquaria", "localhost:38281")
			apclient.room_info_actions.extend (agent on_room_info)
			apclient.connect
			if apclient.is_connected then
				from
					l_command := ""
				until
					l_command ~ "/exit"
				loop
					io.read_line
					l_command := io.last_string
				end
				apclient.close
			else
				print("Cannot connect... Closing.%N")
			end

		end

	on_room_info(a_room_info:AP_ROOM_INFO)
			-- When `a_room_info' has been received from the server.
		local
			l_tags:ARRAYED_LIST[STRING]
		do
			create l_tags.make (1)
			l_tags.extend ("DebugClient")
			print(a_room_info.out)
			apclient.connect_slot ("Louis", "", l_tags, create {AP_ITEM_MANAGEMENT}.make_no_item_handeling,
								create {AP_VERSION}.make (0, 4, 6))
		end

	apclient: AP_CLIENT
			-- The Archipelago client

end
