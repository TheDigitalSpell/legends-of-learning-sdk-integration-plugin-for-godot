class_name StringLib
extends Library


func get_class() -> String: return "StringLib"


# Surrounds the given string with quotes
# @param s: The string to surround with quotes
# @returns: The given string surrounded by quotes
static func quotify(s: String) -> String:
	return "\"" + s + "\""


# Flips all characters in a string to the last is first and vice versa
# @param s: The string to flip
# @returns: The resulting flipped string
static func flip(s: String) -> String:
	var flipped_s = ""
	for c in s:
		flipped_s = c + flipped_s
	return flipped_s


# Returns true if the given string begins with any of the given substrings
# @param s: The string to check
# @param substrings: The strings to check for
# @returns: The resulting flipped string
static func begins_with_any(s: String, substrings: Array) -> bool:
	for substring in substrings:
		if s.begins_with(substring):
			return true
	return false
