note
	description: "Summary description for {AP_VERSION_SERIALIZER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	AP_VERSION_SERIALIZER

inherit
	JSON_SERIALIZER

feature --Conversion

	to_json (a_object: detachable ANY; a_context: JSON_SERIALIZER_CONTEXT): JSON_VALUE
			-- JSON value representing the JSON serialization of `a_object`,
			-- in the eventual context `a_context`.
		local
			l_object: JSON_OBJECT
		do
			if attached {AP_VERSION} a_object as la_version then
				create l_object.make_with_capacity (4)
				l_object.put_integer (la_version.major, "major")
				l_object.put_integer (la_version.minor, "minor")
				l_object.put_integer (la_version.build, "build")
				l_object.put_string ("Version", "class")
				Result := l_object
			else
				create {JSON_NULL} Result
			end
		end

end
