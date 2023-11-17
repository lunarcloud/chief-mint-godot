tool
class_name ChiefMintEditorDefinitionRow, "res://addons/chief_mint/icon/icon.svg"
extends Panel
## Mint Definition Row
## The UI for a single Mint in the editor UI

signal definition_changed(definition, has_changes)

signal definition_removed(definition)

export(Resource) var definition setget set_definition
var unedited: Resource

var name_edit: LineEdit
var max_progress_spin_box: SpinBox
var description_text_edit: TextEdit
var partial_progress_check_box: CheckBox
var rarity_options: OptionButton
var rarity_completion: TextureRect
var icon_display: TextureRect
var changes_label: Label


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
	changes_label = $HBoxContainer/InfoContainer/TopRightArea/ChangesLabel


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
	if def == null:
		definition = null
		unedited = null
		return

	definition = def
	unedited = definition.duplicate()

	if is_instance_valid(changes_label):
		changes_label.visible_characters = 0

	if is_instance_valid(name_edit):
		name_edit.text = def.name

	if is_instance_valid(description_text_edit):
		description_text_edit.text = def.description

	if is_instance_valid(icon_display) and def.icon != null:
		var texture = ImageTexture.new()
		texture.create_from_image(def.icon)
		icon_display.texture = texture

	if is_instance_valid(max_progress_spin_box):
		max_progress_spin_box.value = def.maximum_progress

	if is_instance_valid(partial_progress_check_box):
		partial_progress_check_box.pressed = def.display_partial_progress

	if is_instance_valid(rarity_completion) and is_instance_valid(rarity_options):
		rarity_completion.visible = (
			def.rarity
			== ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION
		)
		rarity_options.visible = not rarity_completion.visible

		if def.rarity < ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION:
			rarity_options.select(def.rarity)
		else:
			$HBoxContainer/InfoContainer/MaxProgressLabel.visible = false
			max_progress_spin_box.visible = false
			$HBoxContainer/InfoContainer/DescriptionLabel.visible = false
			description_text_edit.visible = false
			partial_progress_check_box.visible = false
			$HBoxContainer/InfoContainer/TopRightArea/SubtractButton.visible = false


func on_saved() -> void:
	unedited = definition.duplicate()
	changes_label.visible_characters = 0


func _mark_changed() -> void:
	var diffs = ChiefMintDefinitionResource.differences(unedited, definition)
	var has_changes = diffs.size() > 0

	changes_label.visible_characters = 0 if not has_changes else 1
	emit_signal("definition_changed", unedited, has_changes)
	#print(str("editing result, diffs:", diffs))


func _on_NameEdit_text_changed(new_text):
	definition.name = new_text
	_mark_changed()


func _on_MaxProgressSpinBox_value_changed(value):
	definition.maximum_progress = value
	_mark_changed()


func _on_PartialProgressCheckBox_toggled(button_pressed):
	definition.display_partial_progress = button_pressed
	_mark_changed()


func _on_DescriptionTextEdit_text_changed():
	definition.description = description_text_edit.text
	_mark_changed()


func _on_ImageChangeButton_pressed():
	$ImageFileDialog.show_modal()
	_mark_changed()


func _on_ImageClearButton_pressed():
	definition.icon = null
	icon_display.texture = null


func _on_ImageFileDialog_file_selected(path):
	if not ResourceLoader.exists(path):
		return

	var image = Image.new()
	image.load(path)
	definition.icon = image

	var texture = ImageTexture.new()
	texture.create_from_image(image)
	icon_display.texture = texture

	_mark_changed()


func _on_rarity_selected(index):
	definition.rarity = index
	_mark_changed()
