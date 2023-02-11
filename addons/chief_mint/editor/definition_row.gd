tool
class_name ChiefMintEditorDefinitionRow, "res://addons/chief_mint/icon/icon.svg"
extends Panel

export(Resource) var definition

signal definition_changed(definition)

signal definition_removed(definition)


# Called when the node enters the scene tree for the first time.
func _enter_tree():
	if not definition is ChiefMintDefinitionResource:
		definition = ChiefMintDefinitionResource.new()


func set_editor_scale(value: float) -> void:
	rect_min_size = rect_min_size * value


func _on_SubtractButton_pressed():
	emit_signal("definition_removed", definition)
	queue_free()
