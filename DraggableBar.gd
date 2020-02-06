extends Panel

var parent = null;
var drag = false;
var offset = Vector2(0, 0);

func _ready():
	parent = get_parent();

func _input(event : InputEvent):
	if parent && drag:
		parent.rect_global_position = event.global_position - offset;

func _gui_input(event : InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		drag = event.pressed;
		offset = event.global_position - parent.rect_global_position;
