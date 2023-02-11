tool
class_name ChiefMintEditorDefinitionRow, "res://addons/chief_mint/icon/icon.svg"
extends Panel

export(Resource) var definition

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	if not definition is ChiefMintDefinitionResource:
		definition = ChiefMintDefinitionResource.new()

