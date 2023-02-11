tool
extends Panel

onready var rows : Control = $Vbox/Acheivements/Rows

onready var panel = $Vbox/Panel

const Row := preload("res://addons/chief_mint/editor/definition_row.tscn")

var editor_scale := 1.0 setget set_editor_scale # set once by the plugin

var definitions: ChiefMintDefinitionsResource

func _ready():
	definitions = ChiefMintDefinitionsResource.new()
	for node in rows.get_children():
		if 'definition' in node and node.definition is ChiefMintDefinitionResource:
			definitions.definitions.append(node.definition)


func set_editor_scale(value: float) -> void:
	editor_scale = value
	panel.rect_min_size.y *= value
	for node in rows.get_children():
		if node.has_method("set_editor_scale"):
			node.set_editor_scale(value)


func get_definitions() -> ChiefMintDefinitionsResource:
	var out := ChiefMintDefinitionsResource.new()
	for node in rows.get_children():
		if 'definition' in node and node.definition is ChiefMintDefinitionResource:
			out.definitions.append(node.definition)
	return out


func _on_AddButton_pressed():
	var new_row := Row.instance()
	new_row.definition = ChiefMintDefinitionResource.new()
	new_row.set_editor_scale(editor_scale)
	rows.add_child(new_row)
	new_row.owner = self
	


func _on_SaveButton_pressed():
	pass # Replace with function body.
