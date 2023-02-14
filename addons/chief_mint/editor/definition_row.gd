tool
class_name ChiefMintEditorDefinitionRow, "res://addons/chief_mint/icon/icon.svg"
extends Panel

export(Resource) var definition setget set_definition

var name_edit
var max_progress_spin_box
var description_text_edit
var partial_progress_check_box
var rarity_options: OptionButton
var rarity_completion
var icon_display

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
	rarity_options = $HBoxContainer/InfoContainer/TopRightArea/RarityOptions
	rarity_completion = $HBoxContainer/InfoContainer/TopRightArea/CompletionRarity
	icon_display = $HBoxContainer/IconContainer/ImageDisplay/ImageTexture


func set_editor_scale(value: float) -> void:
	rect_min_size *= value
	$HBoxContainer/InfoContainer/TopRightArea/CompletionRarity.rect_min_size *= value
	$HBoxContainer/InfoContainer/TopRightArea/RarityOptions.rect_min_size *= value
	$HBoxContainer/InfoContainer/TopRightArea/SubtractButton.rect_min_size *= value
	$HBoxContainer/IconContainer/ImageDisplay.rect_min_size *= value


func _on_SubtractButton_pressed():
	emit_signal("definition_removed", definition)
	call_deferred("queue_free")


func set_definition(def: ChiefMintDefinitionResource) -> void:
	definition = def
	if def == null:
		return
	
	if is_instance_valid(name_edit):
		name_edit.text = def.name 
		
	if is_instance_valid(description_text_edit):
		description_text_edit.text = def.description 
		
	if is_instance_valid(icon_display) and ResourceLoader.exists(def.icon_path):
		icon_display.texture = load(def.icon_path)
		
	if is_instance_valid(max_progress_spin_box):
		max_progress_spin_box.value = def.maximum_progress
		
	if is_instance_valid(partial_progress_check_box):
		partial_progress_check_box.pressed = def.display_partial_progress
		
	if is_instance_valid(rarity_completion) and is_instance_valid(rarity_options):
		rarity_completion.visible = def.rarity == ChiefMintDefinitionResource.ChiefMintRarity.Completion
		rarity_options.visible = not rarity_completion.visible
		rarity_options.select(def.rarity)
		if rarity_completion.visible:
			$HBoxContainer/InfoContainer/MaxProgressLabel.visible = false
			max_progress_spin_box.visible = false
			$HBoxContainer/InfoContainer/DescriptionLabel.visible = false
			description_text_edit.visible = false
			partial_progress_check_box.visible = false
			$HBoxContainer/InfoContainer/TopRightArea/SubtractButton.visible = false


func _on_NameEdit_text_changed(new_text):
	definition.name = new_text


func _on_MaxProgressSpinBox_value_changed(value):
	definition.maximum_progress = value


func _on_PartialProgressCheckBox_toggled(button_pressed):
	definition.display_partial_progress = button_pressed


func _on_DescriptionTextEdit_text_changed():
	pass # Replace with function body.


func _on_ImageChangeButton_pressed():
	$ImageFileDialog.show_modal()


func _on_ImageFileDialog_file_selected(path):
	if not ResourceLoader.exists(path):
		return
	definition.icon_path = path
	icon_display.texture = load(path)
