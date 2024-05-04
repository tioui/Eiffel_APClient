note
	description: "Summary description for {AP_MESSAGE_TO_SEND}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

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
