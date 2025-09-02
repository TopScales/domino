##
## Version of the game.
##
@tool
class_name Version
extends Resource

@export_tool_button("Increase fix", "Add") var increase_fix := __tool_button_inc_fix
@export_range(0,10,1,"or_greater") var major := 0
@export_range(0,20,1,"or_greater") var minor := 0
@export_range(0,20,1,"or_greater") var patch := 0
@export var fix := ""
@export_enum("pre-alpha", "alpha", "beta", "dev", "rc", "release") var status := "release"
@export var nickname := ""


# =============================================================
# ========= Public Functions ==================================

static func check_fix_string(string: String) -> String:
	if string.length() > 1:
		return string[0]
	else:
		return string


static func less_than(first: String, second: String) -> bool:
	var first_array := as_array_from_string(first)
	var second_array := as_array_from_string(second)
	for i in first_array.size():
		var v1 := first_array[i]
		var v2 := second_array[i]
		if v1 < v2:
			return true
		elif v1 > v2:
			return false
	return false


static func inc_fix(input_fix: String) -> String:
	if input_fix.is_empty():
		return "a"
	else:
		var ascii := input_fix.to_ascii_buffer()
		assert(ascii.size() == 1, "Version fix field should be a single lowercase letter.")
		var value := ascii[0]
		assert(value >= 97 and value <= 122, "Version fix field should be a single lowercase letter")
		assert(value != 122, "Maximum fix letter reached.")
		ascii[0] = value + 1
		return ascii.get_string_from_ascii()


static func as_array_from_string(string: String) -> PackedInt32Array:
	var res := PackedInt32Array()
	res.resize(4)
	var parts := string.split(".", false)
	assert(parts.size() == 3, "Malformed version string.")
	res[0] = parts[0].to_int()
	res[1] = parts[1].to_int()
	res[2] = parts[2].to_int()
	var fix_letter := parts[2][parts[2].length() - 1]
	var value := fix_letter.to_ascii_buffer()[0]
	if value >= 97 and value <= 122:
		res[3] = value
	else:
		res[3] = 0
	return res


func get_as_string(include_status: bool, include_nickname := false) -> String:
	var string := "%d.%d.%d%s" % [major, minor, patch, fix]
	if include_status:
		string += "-" + status
	if include_nickname:
		return "%s [%s]" % [nickname, string]
	else:
		return string


func get_as_bytes() -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(4)
	bytes.encode_u8(0, major)
	bytes.encode_u8(1, minor)
	bytes.encode_u8(2, patch)
	bytes.encode_u8(3, fix.to_ascii_buffer()[0])
	return bytes


func set_from_bytes(bytes: PackedByteArray) -> void:
	assert(bytes.size() == 4, "Incorrect version buffer size.")
	major = bytes.decode_u8(0)
	minor = bytes.decode_u8(1)
	patch = bytes.decode_u8(2)
	var fix_byte := PackedByteArray([bytes.decode_u8(3)])
	fix = fix_byte.get_string_from_ascii()


# =============================================================
# ========= Callbacks =========================================

func _to_string() -> String:
	return "Version: " + get_as_string(false)


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================

func __tool_button_inc_fix() -> void:
	fix = Version.inc_fix(fix)
	notify_property_list_changed()

# =============================================================
# ========= Signal Callbacks ==================================
