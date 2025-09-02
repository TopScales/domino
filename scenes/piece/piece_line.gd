##
##
class_name PieceLine
extends Control

var _thickness: float = 2.0
var _separation: float = 1.0
var _color: Color = Color.WHITE
var _dash: float = 4.0
var _length: float


# =============================================================
# ========= Public Functions ==================================

func set_thickness(thickness: float) -> void:
	_thickness = thickness
	queue_redraw()


func set_separation(separation: float) -> void:
	_separation = separation
	queue_redraw()


func set_color(color: Color) -> void:
	_color = color
	queue_redraw()


func set_dash(dash: float) -> void:
	_dash = dash
	queue_redraw()


func draw_piece_line(node1: PieceNode, node2: PieceNode) -> void:
	var v: Vector2 = node2.position - node1.position
	var dir: Vector2 = v.normalized()
	var radius: float = node1.get_radius()
	_length = v.length() - 2 * radius
	var perp: Vector2 = Vector2(dir.y, -dir.x)
	size = Vector2(_length, _thickness)
	position = node1.get_center() + dir * radius + perp * _thickness
	rotation = dir.angle()


# =============================================================
# ========= Callbacks =========================================

func _draw() -> void:
	draw_dashed_line(Vector2(_separation, 0.5 * _thickness), Vector2(_length - _separation, 0.5 * _thickness), _color, _thickness, _dash, true, true)


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================


# =============================================================
# ========= Signal Callbacks ==================================
