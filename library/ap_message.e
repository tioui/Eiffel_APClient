note
	description: "Common ancestor of Archipelago message"
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

deferred class
	AP_MESSAGE

feature -- Constants

	Cmd_Identifier:STRING
			-- The identifier of the "cmd" attribute in json message
		deferred
		ensure
			class
		end

end
