note
	description: "Summary description for {AP_WEB_SOCKET_CLIENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	AP_WEB_SOCKET_CLIENT

inherit
	WEB_SOCKET_CLIENT
		redefine
			host
		end

create
	make

feature {NONE} -- Initialisation

	make(a_server:READABLE_STRING_GENERAL)
			-- Initialisation of `Current' using `a_server` as host and port (separaed with :)
		local
			l_server:READABLE_STRING_GENERAL
			l_server_uri:READABLE_STRING_GENERAL
			l_port:INTEGER
			l_server_split:LIST[READABLE_STRING_GENERAL]
		do
			if a_server.starts_with ("ws://") then
				server_uri := a_server
				l_server_uri := a_server.substring (6, a_server.count)
			elseif a_server.starts_with ("wss://") then
				server_uri := a_server
				l_server_uri := a_server.substring (7, a_server.count)
			else
				l_server_uri := a_server
				server_uri := "wss://" + a_server
			end
			create open_actions
			create close_actions
			create error_actions
			create text_message_actions
			create binary_message_actions
			l_server_split := l_server_uri.to_string_32.split ({CHARACTER_32}':')
			l_server := l_server_split.at (1)
			if l_server_split.count > 1 and then l_server_split.at (2).is_natural_16 then
				l_port := l_server_split.at (2).to_integer
				initialize_with_port (l_server, l_port, Void)
			else
				initialize (l_server, Void)
			end
			create implementation.make (create {WEB_SOCKET_NULL_CLIENT}, l_server)
		end

feature -- Access

	server_uri:READABLE_STRING_GENERAL



feature -- Event handlers

	open_actions:ACTION_SEQUENCE[TUPLE[message:STRING]]
			-- Handlers to call when a web socket is opened

	close_actions:ACTION_SEQUENCE[TUPLE[code: INTEGER; reason:STRING]]
			-- Handlers to call when the web socket is closed

	error_actions:ACTION_SEQUENCE[TUPLE[message:STRING]]
			-- Handlers to call when there is a web socket error

	text_message_actions:ACTION_SEQUENCE[TUPLE[message:STRING]]
			-- Handlers to call when the web socket receive a text message

	binary_message_actions:ACTION_SEQUENCE[TUPLE[message:STRING]]
			-- Handlers to call when the web socket receive a binary message


feature {NONE} -- Events API

	on_open (a_message: STRING)
			-- Launched when a web socket is opened.
			-- `a_message` contain the opening message.
		do
			open_actions.call (a_message)
		end

	on_text_message (a_message: STRING)
			-- Launched when a web socket receive a `a_message'.
		do
			text_message_actions.call (a_message)
		end

	on_binary_message (a_message: STRING)
			-- Launched when a web socket receive a binary `a_message'.
		do
			binary_message_actions.call (a_message)
		end

	on_close (a_code: INTEGER; a_reason: STRING)
			-- Launched when a web socket is closed with the closing
			-- code `a_code' and information about the closing in `a_reason'
		do
			close_actions.call (a_code, a_reason)
		end

	on_error (a_error: STRING)
			-- Launched when an error occured in the web socket.
			-- `a_error' is the error message.
		do
			error_actions.call (a_error)
		end

feature {NONE} -- TCP connection

	connection: HTTP_STREAM_SOCKET
		do
			Result := socket
		end

	host: STRING_8
			-- Return an URL
		local
			l_uri: URI
		do
			create Result.make_empty
			create l_uri.make_from_string (server_uri.as_string_8)
			if attached l_uri.host as l_host then
				Result := l_host.as_string_8
			end
		end

end
