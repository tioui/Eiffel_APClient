note
	description: "JSON serializer for object of type {AP_SLOT_CONNECT}."
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

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
		do
			if attached {AP_SLOT_CONNECT_UPDATE} a_object as la_update then
				if attached {AP_SLOT_CONNECT} a_object as la_connect then
					create l_object.make_with_capacity (8)
					l_object.put_string (la_connect.game, "game")
					l_object.put_string (la_connect.uuid, "uuid")
					l_object.put_string (la_connect.name, "name")
					l_object.put_string (la_connect.password, "password")
					a_context.on_field_start ("version")
					l_json_version :=a_context.to_json (la_connect.version, Current)
					l_object.put (l_json_version, "version")
					a_context.on_field_end ("version")
				else
					create l_object.make_with_capacity (3)
					a_context.on_object_serialization_start (a_object)
				end
				l_object.put_string (la_update.cmd, "cmd")
				l_object.put_integer (la_update.items_handling, "items_handling")
				create l_json_tags.make (la_update.tags.count)
				across la_update.tags as la_tags loop
					l_json_tags.extend (create {JSON_STRING}.make_from_string(la_tags.item))
				end
				l_object.put (l_json_tags, "tags")
				Result := l_object
			else
				create {JSON_NULL} Result
			end
		end

end
