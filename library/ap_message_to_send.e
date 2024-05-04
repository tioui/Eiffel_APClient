note
	description: "A common ancestor to every message to send."
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

deferred class
	AP_MESSAGE_TO_SEND

inherit
	AP_MESSAGE
		redefine
			default_create
		end


feature {NONE} -- Initialisation

	default_create
			-- Initialisation of `Current' using `Cmd_Identifier' as `cmd'
		do
			cmd := Cmd_Identifier
		end

feature -- Access

	cmd:STRING
			-- The message identifier


end
