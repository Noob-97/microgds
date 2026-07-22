@tool
extends Control

# Variable de control para evitar que el script se pise a sí mismo
var _is_updating: bool = false

func _ready() -> void:
	child_order_changed.connect(update_y_expansion)
	
	for child in get_children():
		_connect_child_signals(child)
	
	update_y_expansion()

func _notification(what: int) -> void:
	# Corregido: La constante pertenece a la clase Container
	if Engine.is_editor_hint() and what == Container.NOTIFICATION_SORT_CHILDREN:
		update_y_expansion()

func _connect_child_signals(child: Node) -> void:
	if child is Control:
		if !child.resized.is_connected(update_y_expansion):
			child.resized.connect(update_y_expansion)
		if !child.item_rect_changed.is_connected(update_y_expansion):
			child.item_rect_changed.connect(update_y_expansion)

func update_y_expansion() -> void:
	if _is_updating:
		return
		
	_is_updating = true
	
	var max_y: float = 0.0
	var has_valid_children: bool = false
	
	for child in get_children():
		if child is Control and child.visible:
			has_valid_children = true
			_connect_child_signals(child)
			
			var child_bottom = child.position.y + child.size.y
			if child_bottom > max_y:
				max_y = child_bottom
	
	if has_valid_children:
		if !is_equal_approx(custom_minimum_size.y, max_y):
			custom_minimum_size.y = max_y
			
	_is_updating = false
