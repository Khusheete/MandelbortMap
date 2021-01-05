tool
extends HBoxContainer

export(String) var label: String = "Label" setget set_label, get_label

func _ready():
	$Label.text = label

func add_child(node: Node, default: bool = false):
	.add_child(node, default)
	if node is Control:
		node.size_flags_horizontal |= Control.SIZE_EXPAND

func set_label(new_label: String):
	if is_inside_tree():
		$Label.text = new_label
	label = new_label


func get_label() -> String:
	return label


