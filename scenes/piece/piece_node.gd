##
##
class_name PieceNode
extends Control

var _radius: float = 10.0
var _color: Color = Color.WHITE
var _outline_color: Color = Color.BLACK
var _outline_width: float = 1.0


# =============================================================
# ========= Public Functions ==================================

func set_radius(radius: float) -> void:
	_radius = radius
	var sz: float = 2 * (_radius + _outline_width)
	size = Vector2(sz, sz)


func get_radius() -> float:
	return _radius + _outline_width


func set_color(color: Color) -> void:
	_color = color
	queue_redraw()


func set_outline_color(color: Color) -> void:
	_outline_color = color
	queue_redraw()


func set_outline_width(width: float) -> void:
	_outline_width = width
	var sz: float = 2 * (_radius + _outline_width)
	size = Vector2(sz, sz)
	queue_redraw()


func set_center(center: Vector2) -> void:
	var r: float = _radius + _outline_width
	position = center - Vector2(r, r)
	queue_redraw()


func get_center() -> Vector2:
	var r: float = _radius + _outline_width
	return position + Vector2(r, r)


# =============================================================
# ========= Callbacks =========================================

func _draw() -> void:
	var r: float = _radius + _outline_width
	var p: Vector2 = Vector2(r, r)
	draw_circle(p, _radius, _color)
	draw_circle(p, r, _outline_color, false, _outline_width, true)


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================


# =============================================================
# ========= Signal Callbacks ==================================
