tool
class_name ChiefMintEditorDefinitionRow, "res://addons/chief_mint/icon/icon.svg"
extends Panel

export(Resource) var definition setget set_definition

var name_edit
var max_progress_spin_box
var description_text_edit
var partial_progress_check_box

signal definition_changed(definition)

signal definition_removed(definition)


# Called when the node enters the scene tree for the first time.
func _enter_tree():
	if not definition is ChiefMintDefinitionResource:
		definition = ChiefMintDefinitionResource.new()
	
	name_edit = $HBoxContainer/InfoContainer/NameEdit
	max_progress_spin_box = $HBoxContainer/InfoContainer/MaxProgressSpinBox
	description_text_edit = $HBoxContainer/InfoContainer/DescriptionTextEdit
	partial_progress_check_box = $HBoxContainer/InfoContainer/PartialProgressCheckBox

func set_editor_scale(value: float) -> void:
	rect_min_size = rect_min_size * value


func _on_SubtractButton_pressed():
	emit_signal("definition_removed", definition)
	queue_free()


func set_definition(def: ChiefMintDefinitionResource) -> void:
	definition = def
	if def == null:
		return
	if is_instance_valid(name_edit):
		name_edit.text = def.name 
	if is_instance_valid(max_progress_spin_box):
		max_progress_spin_box.value = def.maximum_progress
	if is_instance_valid(partial_progress_check_box):
		partial_progress_check_box.pressed = def.display_partial_progress

func _on_NameEdit_text_changed(new_text):
	definition.name = new_text


func _on_MaxProgressSpinBox_value_changed(value):
	definition.maximum_progress = value


func _on_PartialProgressCheckBox_toggled(button_pressed):
	definition.display_partial_progress = button_pressed


func _on_DescriptionTextEdit_text_changed():
	pass # Replace with function body.


func _on_ImageChangeButton_pressed():
	pass # Replace with function body.
