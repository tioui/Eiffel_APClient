note
	description: "A common ancestor to every message received."
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

deferred class
	AP_MESSAGE_RECEIVED

inherit
	AP_MESSAGE

feature {NONE} -- Initialisation

	make(a_message:JSON_VALUE)
			-- Initialisation of `Current' using `a_message' as `message'.
		do
			message := a_message
		end

feature -- Access

	message:JSON_VALUE
			-- The JSON original message.

end
