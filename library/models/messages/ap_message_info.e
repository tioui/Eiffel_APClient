note
	description: "Information about a message"
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

class
	AP_MESSAGE_INFO

feature -- Class routines

	cmd_message(a_message:JSON_OBJECT):STRING
			-- Get the "cmd" attribute of `a_message'
		do
			Result := ""
			if attached {JSON_STRING} a_message.item("cmd") as la_item then
				Result := la_item.item
			end
		ensure
			class
		end

end
