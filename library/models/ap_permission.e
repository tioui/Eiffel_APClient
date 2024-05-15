note
	description: "Permission of the client."
	author: "Louis M"
	date: "Sat, 04 May 2024 01:35:20 +0000"
	revision: "0.1"

expanded class
	AP_PERMISSION

inherit
	ANY
		redefine
			default_create, out
		end
create
	default_create,
	make

feature {NONE} -- Initialisation

	default_create
			-- Initialisation of `Current'
		do
			make(0)
		end

	make(a_value:INTEGER_64)
			-- Initialisation of `Current' using `a_value' as `value'
		require
			Value_Valid: a_value = 0 or a_value = 1 or a_value = 2 or a_value = 6 or a_value = 7
		do
			value := a_value
		ensure
			Value_Assign: value ~ a_value
		end

feature -- Access

	value:INTEGER_64
			-- The value received from the Archipelago server

	is_disable:BOOLEAN
			-- Completely disables access
		do
			Result := value = 0
		end

	is_enable:BOOLEAN
			-- Allows manual use
		do
			Result := value = 1 or value = 7
		end

	is_goal:BOOLEAN
			-- Allows manual use after goal completion
		do
			Result := value = 2 or value = 1
		end

	is_auto:BOOLEAN
			-- Forces use after goal completion, only works for release and collect
		do
			Result := value = 6 or value = 7
		end

	out:STRING
		do
			Result := ""
			if is_disable then
				Result := "Disabled"
			end
			if is_goal then
				Result := "Manual use enabled after Goal"
			end
			if is_enable then
				Result := "Manual use enabled"
			end
			if is_auto then
				Result := "Force use after Goal completion"
			end
			if is_enable and is_auto then
				Result := "Manual use enabled and force use after Goal completion"
			end
		end

invariant
	Value_Valid: is_disable or is_enable or is_goal or is_auto
	Disable_Valid: is_disable implies (not is_enable and not is_goal and not is_auto)
end
