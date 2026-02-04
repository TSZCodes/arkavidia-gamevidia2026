extends Control

var history_data: Array = []
var min_val: float = 0.0
var max_val: float = 1.0

const MAX_POINTS = 30
const PADDING_PERCENT = 0.02

const COL_UP_LINE = Color(0.2, 0.85, 0.4, 1.0)
const COL_UP_FILL = Color(0.2, 0.85, 0.4, 0.2)
const COL_DOWN_LINE = Color(1.0, 0.3, 0.3, 1.0)
const COL_DOWN_FILL = Color(1.0, 0.3, 0.3, 0.2)

func setup_chart(full_history: Array) -> void:
	if full_history.size() > MAX_POINTS:
		history_data = full_history.slice(-MAX_POINTS)
	else:
		history_data = full_history.duplicate()
	if history_data.is_empty():
		queue_redraw()
		return
	var local_min = history_data[0]
	var local_max = history_data[0]
	for price in history_data:
		if price < local_min: local_min = price
		if price > local_max: local_max = price
	var diff = local_max - local_min
	if diff == 0: diff = max(1.0, local_max * 0.01)
	min_val = local_min - (diff * PADDING_PERCENT)
	max_val = local_max + (diff * PADDING_PERCENT)
	queue_redraw()

func _draw() -> void:
	if history_data.size() < 2: return
	var w = size.x
	var h = size.y
	var count = history_data.size()
	var first_price = history_data[0]
	var last_price = history_data[-1]
	var is_up = last_price >= first_price
	var line_color = COL_UP_LINE if is_up else COL_DOWN_LINE
	var fill_color = COL_UP_FILL if is_up else COL_DOWN_FILL
	var line_points: PackedVector2Array = []
	var poly_points: PackedVector2Array = []
	poly_points.append(Vector2(0, h))
	var range_val = max_val - min_val
	if range_val <= 0.00001: range_val = 1.0
	var step_x = w / max(1, count - 1)
	for i in range(count):
		var price = history_data[i]
		var normalized_y = (price - min_val) / range_val
		var px = i * step_x
		var py = h - (normalized_y * h)
		py = clamp(py, 0, h)
		var point = Vector2(px, py)
		line_points.append(point)
		poly_points.append(point)
	poly_points.append(Vector2(line_points[-1].x, h))
	draw_colored_polygon(poly_points, fill_color)
	draw_polyline(line_points, line_color, 2.0, true)
