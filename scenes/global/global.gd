##
@tool
extends Node

@export var version: Version

@onready var settings: Settings = $Settings
@onready var debug: Debug

var current_composition: CharacterComposition


# =============================================================
# ========= Public Functions ==================================


# =============================================================
# ========= Callbacks =========================================

func _ready() -> void:
	randomize()
	if Engine.is_editor_hint() and version:
		ProjectSettings.set_setting("application/config/version", version.get_as_string(false, false))


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================


# =============================================================
# ========= Signal Callbacks ==================================
