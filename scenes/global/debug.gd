##
##
class_name Debug
extends Node


# =============================================================
# ========= Public Functions ==================================

func make_gui() -> Control:
	var control := Control.new()
	var script := get_script() as Script
	var properties := script.get_script_property_list()
	for prop in properties:
		var type: int = prop["type"]
		var option: Control = null
		var prop_name: StringName = prop["name"]
		match type:
			TYPE_BOOL:
				var button := CheckButton.new()
				button.text = prop_name.capitalize()
				var default := script.get_property_default_value(prop_name) as bool
				button.button_pressed = default
				option = button
			_:
				pass
		control.add_child(option)
	return control


# =============================================================
# ========= Callbacks =========================================


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================


# =============================================================
# ========= Signal Callbacks ==================================
