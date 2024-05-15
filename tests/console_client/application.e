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
			create item_management.make_no_item_handeling
			create {LINKED_LIST[STRING]}tags.make
			tags.compare_objects
			tags.extend ("DebugClient")
			apclient.room_info_actions.extend (agent on_room_info)
			apclient.slot_connected_actions.extend(agent on_slot_connected)
			apclient.connect
			if apclient.is_connected then
				from
					l_command := ""
				until
					l_command ~ "/exit"
				loop
					io.read_line
					l_command := io.last_string
					if l_command ~ "/help" then
						show_help
					elseif l_command.starts_with ("/add tag ") and l_command.count > 9 then
						add_tags(l_command.substring (10, l_command.count))
					elseif l_command.starts_with ("/remove tag ") and l_command.count > 12 then
						remove_tags(l_command.substring (13, l_command.count))
					elseif l_command.starts_with ("/enable item ") then
						enable_item_management(l_command.substring (14, l_command.count))
					elseif l_command.starts_with ("/disable item ") then
						disable_item_management(l_command.substring (15, l_command.count))
					end
				end
				apclient.close
			else
				print("Cannot connect... Closing.%N")
			end
		end

	show_help
			-- Show the help message
		do
			print("/help: Show this help message%N")
			print("/add tag <tag>: Add <tag> to the client tag list%N")
			print("/remove tag <tag>: Remove <tag> to the client tag list%N")
			print("/enable item from self: Receive own items%N")
			print("/enable item from others: Receive items from other world%N")
			print("/enable item starting: Receive every received items when the program started%N")
			print("/disable item handeling: Don't handles items%N")
			print("/disable item from self: Don't receive own items%N")
			print("/disable item from others: Don't receive items from other world%N")
			print("/disable item starting: Don't receive every received items when the program started%N")
			print("/exit: Close the program%N")
		end

	add_tags(a_tag:STRING)
			-- Add `a_tag' in `tags' and update `apclient'
		do
			tags.extend (a_tag)
			apclient.update_slot (tags, item_management)
		end

	remove_tags(a_tag:STRING)
			-- Remove `a_tag' in `tags' and update `apclient'
		do
			tags.prune_all (a_tag)
			apclient.update_slot (tags, item_management)
		end

	enable_item_management(a_management:STRING)
			-- Add an item management in `item_management' and update `apclient'
		local
			l_is_valid:BOOLEAN
		do
			l_is_valid := True
			if a_management.starts_with ("from self") then
				item_management.enable_item_from_self
			elseif a_management.starts_with ("from others") then
				item_management.enable_item_from_others
			elseif a_management.starts_with ("starting") then
				item_management.enable_receiving_starting_items
			else
				print("Item management " + a_management + " is not valid.%N")
				l_is_valid := False
			end
			if l_is_valid then
				apclient.update_slot (tags, item_management)
			end
		end

	disable_item_management(a_management:STRING)
			-- Remove an item management in `item_management' and update `apclient'
		local
			l_is_valid:BOOLEAN
		do
			l_is_valid := True
			if a_management.starts_with ("handeling") then
				item_management.disable_item_handeling
			elseif a_management.starts_with ("from self") then
				item_management.disable_item_from_self
			elseif a_management.starts_with ("from others") then
				item_management.disable_item_from_others
			elseif a_management.starts_with ("starting") then
				item_management.disable_receiving_starting_items
			else
				print("Item management " + a_management + " is not valid.%N")
				l_is_valid := False
			end
			if l_is_valid then
				apclient.update_slot (tags, item_management)
			end
		end

	on_room_info(a_room_info:AP_ROOM_INFO)
			-- At connection, when `a_room_info' has been received from the server.
		local
			l_converter:UTF_CONVERTER
		do
			print(l_converter.utf_32_string_to_utf_8_string_8 (a_room_info.out32))
			print("%N")
			apclient.connect_slot ("Louis", "", tags, item_management, create {AP_VERSION}.make (0, 4, 6))
		end

	on_slot_connected(a_slots_info:AP_SLOT_CONNECTION_INFO)
			-- At slot connection
		local
			l_converter:UTF_CONVERTER
		do
			print(l_converter.utf_32_string_to_utf_8_string_8 (a_slots_info.out32))
			print("%N")
		end

	apclient: AP_CLIENT
			-- The Archipelago client

	item_management: AP_ITEM_MANAGEMENT
			-- The type of item management used in `Current'

	tags:LIST[STRING]
			-- The information tags used in slot connection

end
