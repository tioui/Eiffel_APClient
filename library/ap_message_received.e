note
	description: "Summary description for {AP_MESSAGE_RECEIVED}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	AP_MESSAGE_RECEIVED

inherit
	AP_MESSAGE

feature {NONE} -- Initialisation

	make(a_message:JSON_VALUE)
		do
			message := a_message
		end

feature -- Access

	message:JSON_VALUE

end
