note
	description: "Summary description for {AP_MESSAGE_INFO}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	AP_MESSAGE_INFO

feature -- Class routines

	cmd_message(a_message:JSON_OBJECT):STRING
		local
			l_json_parser:JSON_PARSER
		do
			Result := ""
			if attached {JSON_STRING} a_message.item("cmd") as la_item then
				Result := la_item.item
			end
		ensure
			class
		end

end
