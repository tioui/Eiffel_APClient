note
	description: "A version with 3 numbers (major, minor, build)."
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

class
	AP_VERSION

inherit
	ANY
		redefine
			out
		end

create
	make,
	make_with_json

feature {NONE} -- Initialisation

	make(a_major, a_minor, a_build:INTEGER)
			-- Initialisation of `Current' using `a_major' as `major', `a_minor' as `minor'
			-- and `a_build' as `build'
		do
			major := a_major
			minor := a_minor
			build := a_build
		ensure
			Is_Major_Assign: major ~ a_major
			Is_Minor_Assign: minor ~ a_minor
			Is_Buildr_Assign: build ~ a_build
		end

	make_with_json(a_json:JSON_OBJECT)
			-- Initialisation of `Current' using `a_json' to assign `major', `minor' and `build'
		require
			Is_Version: attached {JSON_STRING} a_json.item ("class") as la_item and then la_item.item ~ "Version"
		local
			l_major:INTEGER
			l_minor:INTEGER
			l_build:INTEGER
		do
			if attached {JSON_NUMBER} a_json.item ("major") as la_major then
				l_major := la_major.integer_64_item.to_integer
			end
			if attached {JSON_NUMBER} a_json.item ("minor") as la_minor then
				l_minor := la_minor.integer_64_item.to_integer
			end
			if attached {JSON_NUMBER} a_json.item ("build") as la_build then
				l_build := la_build.integer_64_item.to_integer
			end
			make(l_major, l_minor, l_build)
		end


feature -- Access

	major:INTEGER assign set_major
			-- The major version number

	minor:INTEGER assign set_minor
			-- The minor version number

	build:INTEGER assign set_build
			-- The build number

	out:STRING
			-- Text representation of `Current'
		do
			Result := major.out + "." + minor.out + "." + build.out
		end

	to_json:STRING
			-- JSON representation of `Current'
		do
			Result := "{%"major%""
		end

feature -- Element change

	set_major(a_major:INTEGER)
			-- Assign `major' with the value of `a_major'
		do
			major := a_major
		ensure
			Is_Assign: major ~ a_major
		end

	set_minor(a_minor:INTEGER)
			-- Assign `minor' with the value of `a_minor'
		do
			minor := a_minor
		ensure
			Is_Assign: minor ~ a_minor
		end

	set_build(a_build:INTEGER)
			-- Assign `build' with the value of `a_build'
		do
			build := a_build
		ensure
			Is_Assign: build ~ a_build
		end

end
