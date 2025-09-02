##
##
extends PanelContainer

const ERROR_NONE: int = 0
const ERROR_EMPTY_NAME: int = 1
const ERROR_WRONG_FORMAT: int = 2
const ERROR_SOCKET_EXIST: int = 3
const ERROR_CATEGORY_EXIST: int = 4

@export var socket_group: ButtonGroup
@export var categories: Control
@export var new_category_dialog: ConfirmationDialog
@export var category_warning_label: Label
@export var new_category_name: LineEdit
@export var socket_dialog: ConfirmationDialog
@export var socket_name_edit: LineEdit
@export var socket_parent_options: OptionButton
@export var socket_create_bone_check_box: CheckBox
@export var socket_warning_label: Label
@export var delete_dialog: ConfirmationDialog

var _error: int = ERROR_EMPTY_NAME
var _current_category: String = ""
var _current_socket: int = -1

# =============================================================
# ========= Public Functions ==================================


# =============================================================
# ========= Callbacks =========================================


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================

func __update_new_category_error(error: int) -> void:
	if error != _error:
		_error = error
		if _error == ERROR_NONE:
			category_warning_label.hide()
			new_category_dialog.get_ok_button().disabled = false
		else:
			category_warning_label.show()
			new_category_dialog.get_ok_button().disabled = true

			match _error:
				ERROR_EMPTY_NAME:
					category_warning_label.text = "⚠️ Category name can't be empty."
				ERROR_WRONG_FORMAT:
					category_warning_label.text = "⚠️ Incorrect Category name format."
				ERROR_CATEGORY_EXIST:
					category_warning_label.text = "⚠️ Category already exists."
				ERROR_SOCKET_EXIST:
					category_warning_label.text = "⚠️ Socket already exists."


func __update_socket_error(error: int) -> void:
	if error != _error:
		_error = error
		if _error == ERROR_NONE:
			socket_warning_label.hide()
			socket_dialog.get_ok_button().disabled = false
		else:
			socket_warning_label.show()
			socket_dialog.get_ok_button().disabled = true

			match _error:
				ERROR_EMPTY_NAME:
					socket_warning_label.text = "⚠️ Socket name can't be empty."
				ERROR_WRONG_FORMAT:
					socket_warning_label.text = "⚠️ Incorrect Socket name format."
				ERROR_SOCKET_EXIST:
					socket_warning_label.text = "⚠️ Socket already exists."


func __add_category(category: String, folded: bool) -> void:
	var category_container: FoldableContainer = FoldableContainer.new()
	var category_node_name: String = category.capitalize()
	category_container.name = category_node_name
	category_container.title = category_node_name
	category_container.folded = folded
	category_container.grab_focus.call_deferred()
	category_container.add_theme_stylebox_override(&"panel", preload("uid://b7xdl5gu121vb"))
	categories.add_child(category_container)
	var add_socket_button: Button = Button.new()
	add_socket_button.name = "AddSocket"
	add_socket_button.icon = preload("uid://dq276cqoyrj71")
	add_socket_button.flat = true
	add_socket_button.pressed.connect(_on_add_socket_pressed.bind(category))
	category_container.add_title_bar_control(add_socket_button)
	var delete_category_button: Button = Button.new()
	delete_category_button.name = "RemoveCategory"
	delete_category_button.icon = preload("uid://c2qt7o8hw8ruo")
	delete_category_button.flat = true
	delete_category_button.pressed.connect(_on_delete_category_pressed.bind(category))
	category_container.add_title_bar_control(delete_category_button)
	var box: VBoxContainer = VBoxContainer.new()
	box.name = "SocketContainer"
	category_container.add_child(box)


func __add_socket(socket: String, category: String) -> void:
	var category_node_name: String = category.capitalize()
	if not categories.has_node(category_node_name):
		__add_category(category, false)
	var category_container: FoldableContainer = categories.get_node(category_node_name)
	var socket_node_name: String = socket.capitalize()
	var socket_button: Button = Button.new()
	socket_button.name = "SocketButton"
	socket_button.text = socket_node_name
	socket_button.toggle_mode = true
	socket_button.button_group = socket_group
	socket_button.button_pressed = true
	socket_button.pressed.connect(_on_socket_pressed.bind(socket, category))
	socket_button.size_flags_horizontal |= Control.SIZE_EXPAND
	var socket_box: HBoxContainer = HBoxContainer.new()
	socket_box.name = socket_node_name
	socket_box.add_child(socket_button)
	var edit_button: Button = Button.new()
	edit_button.name = "Edit"
	edit_button.icon = preload("uid://der2v6w4q4dy4")
	edit_button.flat = true
	edit_button.pressed.connect(_on_edit_socket_pressed.bind(socket, category))
	socket_box.add_child(edit_button)
	var delete_button: Button = Button.new()
	delete_button.name = "Remove"
	delete_button.icon = preload("uid://c36l00yqxr8yo")
	delete_button.flat = true
	delete_button.pressed.connect(_on_delete_socket_pressed.bind(socket, category))
	socket_box.add_child(delete_button)
	var box: VBoxContainer = category_container.get_node("SocketContainer")
	box.add_child(socket_box)
	category_container.expand()


func __show_socket_edit_dialog() -> void:
	socket_parent_options.clear()
	socket_parent_options.add_item("NONE", Global.current_composition.get_socket_count())
	var parents_map: Dictionary[int, String] = Global.current_composition.get_available_parents(_current_socket)
	for id in parents_map:
		var socket_name: String = parents_map[id]
		socket_parent_options.add_item(socket_name.capitalize(), id)
	if _current_socket == -1:
		socket_name_edit.text = ""
		socket_parent_options.select(0)
		socket_create_bone_check_box.button_pressed = true
		socket_dialog.title = "New Socket..."
		socket_dialog.get_ok_button().disabled = true
	else:
		socket_name_edit.text = Global.current_composition.get_socket_name(_current_socket)
		socket_create_bone_check_box.button_pressed = Global.current_composition.get_socket_create_bone(_current_socket)
		var socket_parent: int = Global.current_composition.get_socket_parent(_current_socket)
		if socket_parent == -1:
			socket_parent = Global.current_composition.get_socket_count()
		var parent_index: int = socket_parent_options.get_item_index(socket_parent)
		socket_parent_options.select(parent_index)
		socket_dialog.title = "Edit Socket..."
		socket_dialog.get_ok_button().disabled = false
	_error = ERROR_EMPTY_NAME
	socket_dialog.popup_centered()


# =============================================================
# ========= Signal Callbacks ==================================


func _on_add_category_pressed() -> void:
	_error = ERROR_EMPTY_NAME
	category_warning_label.hide()
	new_category_name.text = ""
	new_category_dialog.get_ok_button().disabled = true
	new_category_dialog.popup_centered()


func _on_new_category_dialog_confirmed() -> void:
	var category_text: String = new_category_name.text
	if category_text.contains("/"):
		var parts: PackedStringArray = category_text.split("/")
		if parts.size() != 2:
			printerr("Incorrect category name format.")
			return
		var category: String = parts[0].strip_edges().to_snake_case()
		var socket: String = parts[1].strip_edges().to_snake_case()
		Global.current_composition.add_category_socket(category, socket)
		__add_socket(socket, category)
	else:
		var category: String = category_text.strip_edges().to_snake_case()
		Global.current_composition.add_category(category)
		__add_category(category, true)


func _on_new_category_name_text_changed(new_text: String) -> void:
	if new_text.contains("/"):
		var parts: PackedStringArray = new_text.split("/", false)
		if parts.size() != 2:
			__update_new_category_error(ERROR_WRONG_FORMAT)
			return
		var category: String = parts[0].strip_edges().to_snake_case()
		var socket: String = parts[1].strip_edges().to_snake_case()
		if Global.current_composition.has_category_socket(socket, category):
			__update_new_category_error(ERROR_SOCKET_EXIST)
		else:
			__update_new_category_error(ERROR_NONE)
	else:
		var category: String = new_text.strip_edges().to_snake_case()
		if Global.current_composition.has_category(category):
			__update_new_category_error(ERROR_CATEGORY_EXIST)
		else:
			__update_new_category_error(ERROR_NONE)


func _on_socket_pressed(socket: String, category: String) -> void:
	print("Socket: %s, Category: %s" % [socket, category])


func _on_add_socket_pressed(category: String) -> void:
	_current_category = category
	_current_socket = -1
	__show_socket_edit_dialog()


func _on_delete_category_pressed(category: String) -> void:
	delete_dialog.dialog_text = "Remove category %s?" % category.capitalize()
	delete_dialog.set_meta(&"is_category", true)
	delete_dialog.set_meta(&"category", category)
	delete_dialog.popup_centered()


func _on_socket_dialog_confirmed() -> void:
	var id: int = _current_socket
	var parent_id: int = socket_parent_options.get_selected_id()
	if parent_id == Global.current_composition.get_socket_count():
		parent_id = -1
	if id == -1:
		var socket_name: String = socket_name_edit.text
		id = Global.current_composition.add_category_socket(_current_category, socket_name)
		__add_socket(socket_name, _current_category)
	else:
		Global.current_composition.set_socket_name(id, socket_name_edit.text)
	Global.current_composition.set_socket_parent(id, parent_id)
	Global.current_composition.set_socket_create_bone(id, socket_create_bone_check_box.button_pressed)
	socket_warning_label.hide()


func _on_socket_name_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		__update_socket_error(ERROR_EMPTY_NAME)
	elif Global.current_composition.has_category_socket(_current_category, new_text):
		__update_socket_error(ERROR_SOCKET_EXIST)
	else:
		__update_socket_error(ERROR_NONE)


func _on_delete_dialog_confirmed() -> void:
	var category: String = delete_dialog.get_meta(&"category", "")
	var category_node_name: String = category.capitalize()
	if delete_dialog.get_meta(&"is_category", false):
		categories.remove_child(categories.get_node(category_node_name))
		Global.current_composition.remove_category(category)
	else:
		var socket: String = delete_dialog.get_meta(&"socket", "")
		var socket_node_name: String = socket.capitalize()
		var category_node: Control = categories.get_node(category_node_name)
		var box: VBoxContainer = category_node.get_node("SocketContainer")
		box.remove_child(box.get_node(socket_node_name))
		Global.current_composition.remove_category_socket(category, socket)


func _on_edit_socket_pressed(socket: String, category: String) -> void:
	_current_category = category
	_current_socket = Global.current_composition.get_category_socket_index(category, socket)
	__show_socket_edit_dialog()


func _on_delete_socket_pressed(socket: String, category: String) -> void:
	delete_dialog.dialog_text = "Remove socket %s?" % socket.capitalize()
	delete_dialog.set_meta(&"is_category", false)
	delete_dialog.set_meta(&"category", category)
	delete_dialog.set_meta(&"socket", socket)
	delete_dialog.popup_centered()
