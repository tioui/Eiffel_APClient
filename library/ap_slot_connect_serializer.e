note
	description: "Summary description for {AP_SLOT_CONNECT_SERIALIZER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	AP_SLOT_CONNECT_SERIALIZER

inherit
	JSON_SERIALIZER

feature --Conversion

	to_json (a_object: detachable ANY; a_context: JSON_SERIALIZER_CONTEXT): JSON_VALUE
			-- JSON value representing the JSON serialization of `a_object`,
			-- in the eventual context `a_context`.
		local
			l_object: JSON_OBJECT
			l_json_version:JSON_VALUE
			l_json_tags:JSON_ARRAY
			l_index:INTEGER
		do
			if attached {AP_SLOT_CONNECT} a_object as la_message then
				create l_object.make_with_capacity (8)
				a_context.on_object_serialization_start (a_object)
				l_object.put_string (la_message.cmd, "cmd")
				l_object.put_string (la_message.game, "game")
				l_object.put_string (la_message.uuid, "uuid")
				l_object.put_string (la_message.name, "name")
				l_object.put_string (la_message.password, "password")
				l_object.put_integer (la_message.items_handling, "items_handling")
				a_context.on_field_start ("version")
				l_json_version :=a_context.to_json (la_message.version, Current)
				l_object.put (l_json_version, "version")
				a_context.on_field_end ("version")
				create l_json_tags.make (la_message.tags.count)
				across la_message.tags as la_tags loop
					l_json_tags.extend (create {JSON_STRING}.make_from_string(la_tags.item))
				end
				l_object.put (l_json_tags, "tags")
				Result := l_object
			else
				create {JSON_NULL} Result
			end
		end

end
