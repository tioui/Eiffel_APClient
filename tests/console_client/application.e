note
	description: "console_client application root class"
	date: "$Date$"
	revision: "$Revision$"

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
			create apclient.make ("Aquaria", "ws://localhost:38281")
			apclient.room_info_actions.extend (agent on_room_info)
			apclient.connect
			from
				l_command := ""
			until
				l_command ~ "/exit"
			loop
				io.read_line
				l_command := io.last_string
			end
		end

	on_room_info(a_room_info:AP_ROOM_INFO)
		local
			l_tags:ARRAYED_LIST[STRING]
		do
			create l_tags.make (1)
			l_tags.extend ("DebugClient")
			print(a_room_info.out)
			apclient.connect_slot ("Louis", "", l_tags, create {AP_SLOT_FLAG}.make_no_item_handeling,
								create {AP_VERSION}.make (0, 4, 6))
		end

	apclient: AP_CLIENT

end
