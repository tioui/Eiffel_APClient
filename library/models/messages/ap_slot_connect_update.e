note
	description: "Summary description for {AP_SLOT_CONNECT_UPDATE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	AP_SLOT_CONNECT_UPDATE

inherit
	AP_MESSAGE_TO_SEND

create
	make

feature {NONE} -- Initialisation

	make(a_items_handling: AP_ITEM_MANAGEMENT; a_tags:LIST[STRING])
		do
			default_create
			items_handling := a_items_handling.value
			create {ARRAYED_LIST[STRING]}tags.make (a_tags.count)
			tags.compare_objects
			across a_tags as la_tags loop
				tags.extend(la_tags.item.twin)
			end
		ensure
			Is_Cmd_Valid: cmd ~ Cmd_identifier
			Is_Items_Handling_Valid: items_handling ~ a_items_handling.value
			Is_Tags_Valid: tags ~ a_tags
		end



feature -- Access

	items_handling: INTEGER
			-- The item handling flags

	tags: LIST[STRING]
			-- The tags of the connection slot


feature -- Constants

	Cmd_Identifier:STRING
			-- JSON message cmd identifier for a Slot connection update
		once
			Result := "ConnectUpdate"
		end


end
