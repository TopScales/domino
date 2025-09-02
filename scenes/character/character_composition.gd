##
##
class_name CharacterComposition
extends Resource

class Socket:
	var name: String = ""
	var parent: int = -1
	var position: Vector2 = Vector2.ZERO
	var offset: Vector2 = Vector2.ZERO
	var create_bone: bool = true

class Category:
	var name: String = ""
	var sockets: PackedInt32Array = []


var _categories: Array[Category] = []
var _sockets: Array[Socket] = []


# =============================================================
# ========= Public Functions ==================================

func has_category(category_name: String) -> bool:
	if __get_category(category_name):
		return true
	else:
		return false


func has_category_socket(category_name: String, socket_name: String) -> bool:
	var category: Category = __get_category(category_name)
	if category and __get_socket(socket_name, category):
		return true
	return false


func add_category(category_name: String) -> void:
	__add_category(category_name)


func remove_category(category_name: String) -> void:
	var category_index: int = __get_category_index(category_name)
	var category: Category = _categories[category_index]
	var new_sockets: Array[Socket] = []
	new_sockets.resize(_sockets.size() - category.sockets.size())
	var socket_map: Dictionary[int, int] = {}
	var count: int = 0
	for i in _sockets.size():
		if not category.sockets.has(i):
			new_sockets[count] = _sockets[i]
			socket_map[i] = count
			count += 1
	_sockets = new_sockets
	_categories.remove_at(category_index)
	for i in _categories.size():
		var c: Category = _categories[i]
		for j in c.sockets.size():
			c.sockets[j] = socket_map[c.sockets[j]]
	notify_property_list_changed()


func add_category_socket(category_name: String, socket_name: String) -> int:
	var category: Category = __get_category(category_name)
	if not category:
		category = __add_category(category_name)
	var socket: Socket = Socket.new()
	socket.name = socket_name
	category.sockets.push_back(_sockets.size())
	_sockets.push_back(socket)
	notify_property_list_changed()
	return _sockets.size() - 1


func remove_category_socket(category_name: String, socket_name: String) -> void:
	var category: Category = __get_category(category_name)
	if not category:
		printerr("Category '%s' not found while trying to remove socket %s" % [category_name, socket_name])
		return
	var socket_index: int = __get_socket_index(socket_name, category)
	_sockets.remove_at(socket_index)
	category.sockets.erase(socket_index)
	for i in _categories.size():
		var c: Category = _categories[i]
		for j in c.sockets.size():
			var index: int = c.sockets[j]
			if index > socket_index:
				c.sockets[j] = index - 1


func get_categories() -> PackedStringArray:
	var category_names: PackedStringArray
	category_names.resize(_categories.size())
	for i in _categories.size():
		category_names[i] = _categories[i].name
	return category_names


func get_category_socket_names(category_name: String) -> PackedStringArray:
	var socket_names: PackedStringArray = []
	var category: Category = __get_category(category_name)
	socket_names.resize(category.sockets.size())
	for i in category.sockets.size():
		var socket: Socket = _sockets[category.sockets[i]]
		socket_names[i] = socket.name
	return socket_names


func get_category_socket_index(category_name: String, socket_name: String) -> int:
	var category: Category = __get_category(category_name)
	return __get_socket_index(socket_name, category)


func get_socket_count() -> int:
	return _sockets.size()


func set_socket_name(socket_index: int, new_name: String) -> void:
	_sockets[socket_index].name = new_name


func get_socket_name(socket_index: int) -> String:
	return _sockets[socket_index].name


func set_socket_parent(socket_index: int, new_parent: int) -> void:
	_sockets[socket_index].parent = new_parent


func get_socket_parent(socket_index: int) -> int:
	return _sockets[socket_index].parent


func set_socket_position(socket_index: int, new_position: Vector2) -> void:
	_sockets[socket_index].position = new_position


func get_socket_position(socket_index: int) -> Vector2:
	return _sockets[socket_index].position


func set_socket_offset(socket_index: int, new_offset: Vector2) -> void:
	_sockets[socket_index].offset = new_offset


func get_socket_offset(socket_index: int) -> Vector2:
	return _sockets[socket_index].offset


func set_socket_create_bone(socket_index: int, new_create_bone: bool) -> void:
	_sockets[socket_index].create_bone = new_create_bone


func get_socket_create_bone(socket_index: int) -> bool:
	return _sockets[socket_index].create_bone


func get_available_parents(index: int) -> Dictionary[int, String]:
	var parents: Dictionary[int, String] = {}
	for i in _sockets.size():
		if i != index:
			var socket: Socket = _sockets[i]
			if socket.create_bone:
				parents[i] = socket.name
	return parents


#func move_category_socket(category_name: String, socket_index: int, to: int) -> void:
	#var category: Category = __get_category(category_name)
	#var index: int = category.sockets[socket_index]
	##var i1: int =
	## si < to
	## -1 to [si + 1, to]
	#category.sockets
	#notify_property_list_changed()



# =============================================================
# ========= Callbacks =========================================

func _set(property: StringName, value: Variant) -> bool:
	if property == &"num_categories":
		_categories.resize(value)
		for i in _categories.size():
			_categories[i] = Category.new()
		return true
	elif property == &"num_sockets":
		_sockets.resize(value)
		for i in _sockets.size():
			_sockets[i] = Socket.new()
		return true
	elif property == &"category_names":
		__set_category_names(value)
		return true
	elif property == &"category_sockets":
		__set_category_sockets(value)
		return true
	elif property == &"socket_names":
		__set_socket_names(value)
		return true
	elif property == &"parents":
		__set_parents(value)
		return true
	elif property == &"positions":
		__set_positions(value)
		return true
	elif property == &"offsets":
		__set_offsets(value)
		return true
	elif property == &"create_bones":
		__set_create_bones(value)
		return true
	elif property.contains("/"):
		var parts: PackedStringArray = property.split("/")
		var prop: String = parts[1]
		parts = parts[0].split("_")
		var socket_index: int = parts[1].to_int()
		return __set_socket_property(socket_index, prop, value)
	return false


func _get(property: StringName) -> Variant:
	if property == &"num_categories":
		return _categories.size()
	elif property == &"num_sockets":
		return _sockets.size()
	elif property == &"category_names":
		return __get_category_names()
	elif property == &"category_sockets":
		return __get_category_sockets()
	elif property == &"socket_names":
		return __get_socket_names()
	elif property == &"parents":
		return __get_parents()
	elif property == &"positions":
		return __get_positions()
	elif property == &"offsets":
		return __get_offsets()
	elif property == &"create_bones":
		return __get_create_bones()
	elif property.contains("/"):
		var parts: PackedStringArray = property.split("/")
		var prop: String = parts[1]
		parts = parts[0].split("_")
		var socket_index: int = parts[1].to_int()
		return __get_socket_property(socket_index, prop)
	return null


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []

	# Properties shown only in the editor.
	for i in _categories.size():
		var category: Category = _categories[i]
		props.push_back({
			"name": category.name,
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP
		})
		var sockets: PackedInt32Array = category.sockets
		for j in sockets.size():
			var socket_index: int = sockets[j]
			var socket: Socket = _sockets[socket_index]
			var socket_prefix: String = "socket_%d/" % j
			props.push_back({
				"name": socket.name,
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_SUBGROUP,
				"hint_string": socket_prefix
			})
			props.push_back({
				"name": socket_prefix + "name",
				"type": TYPE_STRING,
				"usage": PROPERTY_USAGE_EDITOR
			})
			props.push_back({
				"name": socket_prefix + "parent",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_EDITOR,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": __get_available_parents(socket_index)
			})
			props.push_back({
				"name": socket_prefix + "position",
				"type": TYPE_VECTOR2,
				"usage": PROPERTY_USAGE_EDITOR
			})
			props.push_back({
				"name": socket_prefix + "offset",
				"type": TYPE_VECTOR2,
				"usage": PROPERTY_USAGE_EDITOR
			})
			props.push_back({
				"name": socket_prefix + "create_bone",
				"type": TYPE_BOOL,
				"usage": PROPERTY_USAGE_EDITOR
			})

	# Properties that are stored.
	props.push_back({
		"name": "num_categories",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_STORAGE
	})
	props.push_back({
		"name": "num_sockets",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_STORAGE
	})

	props.push_back({
		"name": "category_names",
		"type": TYPE_PACKED_STRING_ARRAY,
		"usage": PROPERTY_USAGE_STORAGE
	})
	props.push_back({
		"name": "category_sockets",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_STORAGE,
		"hint": PROPERTY_HINT_ARRAY_TYPE,
		"hint_string": "%d:" % [TYPE_PACKED_INT32_ARRAY]
	})
	props.push_back({
		"name": "socket_names",
		"type": TYPE_PACKED_STRING_ARRAY,
		"usage": PROPERTY_USAGE_STORAGE
	})
	props.push_back({
		"name": "parents",
		"type": TYPE_PACKED_INT32_ARRAY,
		"usage": PROPERTY_USAGE_STORAGE
	})
	props.push_back({
		"name": "positions",
		"type": TYPE_PACKED_VECTOR2_ARRAY,
		"usage": PROPERTY_USAGE_STORAGE
	})
	props.push_back({
		"name": "offsets",
		"type": TYPE_PACKED_VECTOR2_ARRAY,
		"usage": PROPERTY_USAGE_STORAGE
	})
	props.push_back({
		"name": "create_bones",
		"type": TYPE_PACKED_BYTE_ARRAY,
		"usage": PROPERTY_USAGE_STORAGE
	})

	return props


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================

func __add_category(category_name: String) -> Category:
	var category: Category = Category.new()
	category.name = category_name
	_categories.push_back(category)
	notify_property_list_changed()
	return category


func __set_socket_property(socket_index: int, property_name: String, value: Variant) -> bool:
	var socket: Socket = _sockets[socket_index]
	if property_name == "name":
		socket.name = value
		return true
	elif property_name == "parent":
		socket.parent = value
		return true
	elif property_name == "position":
		socket.position = value
		return true
	elif property_name == "offset":
		socket.offset = value
		return true
	elif property_name == "create_bone":
		socket.create_bone = value
		return true
	return false

func __set_category_names(names: PackedStringArray) -> void:
	for i in _categories.size():
		var category_name: String = names[i]
		var category: Category = _categories[i]
		category.name = category_name


func __set_category_sockets(sockets_array: Array[PackedInt32Array]) -> void:
	for i in _categories.size():
		var sockets: PackedInt32Array = sockets_array[i]
		var category: Category = _categories[i]
		category.sockets = sockets


func __set_socket_names(names: PackedStringArray) -> void:
	for i in _sockets.size():
		var socket_name: String = names[i]
		var socket: Socket = _sockets[i]
		socket.name = socket_name


func __set_parents(parents: PackedInt32Array) -> void:
	for i in _sockets.size():
		_sockets[i].parent = parents[i]


func __set_positions(positions: PackedVector2Array) -> void:
	for i in _sockets.size():
		_sockets[i].position = positions[i]


func __set_offsets(offsets: PackedVector2Array) -> void:
	for i in _sockets.size():
		_sockets[i].offset = offsets[i]


func __set_create_bones(create_bones: PackedByteArray) -> void:
	for i in _sockets.size():
		_sockets[i].create_bone = create_bones[i]


func __get_socket_property(socket_index: int, property_name: String) -> Variant:
	var socket: Socket = _sockets[socket_index]
	if property_name == "name":
		return socket.name
	elif property_name == "parent":
		return socket.parent
	elif property_name == "position":
		return socket.position
	elif property_name == "offset":
		return socket.offset
	elif property_name == "create_bone":
		return socket.create_bone
	return null


func __get_available_parents(socket_index: int) -> String:
	var result: String = "NONE:-1"
	for i in _sockets.size():
		if socket_index != i:
			var socket: Socket = _sockets[i]
			if socket.create_bone:
				result += ",%s:%d" % [socket.name, i]
	return result


func __get_category_names() -> PackedStringArray:
	var names: PackedStringArray = []
	names.resize(_categories.size())
	for i in _categories.size():
		names[i] = _categories[i].name
	return names


func __get_category_sockets() -> Array[PackedInt32Array]:
	var sockets_array: Array[PackedInt32Array] = []
	sockets_array.resize(_categories.size())
	for i in _categories.size():
		sockets_array[i] = _categories[i].sockets
	return sockets_array


func __get_socket_names() -> PackedStringArray:
	var names: PackedStringArray = []
	names.resize(_sockets.size())
	for i in _sockets.size():
		names[i] = _sockets[i].name
	return names


func __get_parents() -> PackedInt32Array:
	var parents: PackedInt32Array = []
	parents.resize(_sockets.size())
	for i in _sockets.size():
		parents[i] = _sockets[i].parent
	return parents


func __get_positions() -> PackedVector2Array:
	var positions: PackedVector2Array = []
	positions.resize(_sockets.size())
	for i in _sockets.size():
		positions[i] = _sockets[i].position
	return positions


func __get_offsets() -> PackedVector2Array:
	var offsets: PackedVector2Array = []
	offsets.resize(_sockets.size())
	for i in _sockets.size():
		offsets[i] = _sockets[i].offset
	return offsets


func __get_create_bones() -> PackedByteArray:
	var create_bones: PackedByteArray = []
	create_bones.resize(_sockets.size())
	for i in _sockets.size():
		create_bones[i] = int(_sockets[i].create_bone)
	return create_bones


func __get_category(category_name: String) -> Category:
	for i in _categories.size():
		var category: Category = _categories[i]
		if category.name == category_name:
			return category
	return null


func __get_category_index(category_name: String) -> int:
	for i in _categories.size():
		var category: Category = _categories[i]
		if category.name == category_name:
			return i
	return -1


func __get_socket(socket_name: String, category: Category) -> Socket:
	for i in category.sockets.size():
		var socket: Socket = _sockets[category.sockets[i]]
		if socket.name == socket_name:
			return socket
	return null


func __get_socket_index(socket_name: String, category: Category) -> int:
	for i in category.sockets.size():
		var socket: Socket = _sockets[category.sockets[i]]
		if socket.name == socket_name:
			return i
	return -1


# =============================================================
# ========= Signal Callbacks ==================================
