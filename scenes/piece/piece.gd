##
##
class_name Piece
extends Control

@export_group("Nodes", "node_")
@export var node_radius: float = 10.0:
	set(value):
		node_radius = value
		for i in _nodes.size():
			_nodes[i].set_radius(node_radius)
@export var node_color: Color = Color.WHITE:
	set(value):
		node_color = value
		for i in _nodes.size():
			_nodes[i].set_color(node_color)
@export var node_outline_color: Color = Color.BLACK:
	set(value):
		node_outline_color = value
		for i in _nodes.size():
			_nodes[i].set_outline_color(node_outline_color)
@export var node_outline_width: float = 1.0:
	set(value):
		node_outline_width = value
		for i in _nodes.size():
			_nodes[i].set_outline_width(node_outline_width)
@export_group("Lines", "line_")
@export var line_thickness: float = 2.0:
	set(value):
		line_thickness = value
		for i in _lines.size():
			_lines[i].set_thickness(line_thickness)
@export var line_separation: float = 1.0:
	set(value):
		line_separation = value
		for i in _lines.size():
			_lines[i].set_separation(line_separation)
@export var line_color: Color = Color.WHITE:
	set(value):
		line_color = value
		for i in _lines.size():
			_lines[i].set_color(line_color)
@export var line_dash: float = 4.0:
	set(value):
		line_dash = value
		for i in _lines.size():
			_lines[i].set_dash(line_dash)

var _nodes: Array[PieceNode] = []
var _lines: Array[PieceLine] = []


# =============================================================
# ========= Public Functions ==================================

func set_node_positions(positions: PackedVector2Array) -> void:
	_nodes.resize(positions.size())
	_lines.resize(positions.size())
	var maxx: float = -1e20
	var minx: float = 1e20
	var maxy: float = -1e20
	var miny: float = 1e20

	for i in positions.size():
		var p: Vector2 = positions[i]
		maxx = maxf(p.x, maxx)
		minx = minf(p.x, minx)
		maxy = maxf(p.y, maxy)
		miny = minf(p.y, miny)

	position = Vector2(minx, miny)
	size = Vector2(maxx - minx, maxy - miny)

	for i in _nodes.size():
		var node: PieceNode = PieceNode.new()
		__set_node_params(node)
		var p: Vector2 = positions[i] - position
		node.set_center(p)
		add_child(node)
		_nodes[i] = node
		maxx = maxf(p.x, maxx)
		minx = minf(p.x, minx)
		maxy = maxf(p.y, maxy)
		miny = minf(p.y, miny)

	for i2 in _lines.size():
		var line: PieceLine = PieceLine.new()
		__set_line_params(line)
		var i1: int = i2 - 1 if i2 != 0 else _nodes.size() - 1
		var node1: PieceNode = _nodes[i1]
		var node2: PieceNode = _nodes[i2]
		line.draw_piece_line(node1, node2)
		add_child(line)
		_lines[i1] = line


func cover_rect(rect: Rect2) -> void:
	var positions: PackedVector2Array = [
		rect.position, rect.position + Vector2(rect.size.x, 0),
		rect.end, rect.position + Vector2(0, rect.size.y)
	]
	set_node_positions(positions)


# =============================================================
# ========= Callbacks =========================================

func _ready() -> void:
	cover_rect(Rect2(Vector2(100, 100), Vector2(100, 100)))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color.GREEN)

#func _notification(what: int) -> void:
	#if what == NOTIFICATION_RESIZED:
		#pass


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================

func __set_node_params(node: PieceNode) -> void:
	node.set_radius(node_radius)
	node.set_color(node_color)
	node.set_outline_color(node_outline_color)
	node.set_outline_width(node_outline_width)


func __set_line_params(line: PieceLine) -> void:
	line.set_thickness(line_thickness)
	line.set_color(line_color)
	line.set_separation(line_separation)
	line.set_dash(line_dash)


# =============================================================
# ========= Signal Callbacks ==================================
