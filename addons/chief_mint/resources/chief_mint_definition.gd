class_name ChiefMintDefinitionResource, "res://addons/chief_mint/icon/icon.svg"
extends Resource

enum ChiefMintRarity {
	Common = 0,
	Uncommon = 1,
	Rare = 2,
	Completion = 3
}


export var name: String

export var description: String

export var icon_path: String

export(int, 1, 255, 1) var maximum_progress: int = 1

export var display_partial_progress: bool = true

export(int, "Common", "Uncommon", "Rare", "Completion") var rarity := ChiefMintRarity.Common


func _init():
	self.resource_name = "Chief Mint Definition Resource"


# Add support for is_class
func is_class(name : String) -> bool:
	return name == "ChiefMintDefinitionResource" or .is_class(name)


static func differences(a: ChiefMintDefinitionResource, b: ChiefMintDefinitionResource) -> Array:
	if a == null:
		push_warning("Comparing with null resource a!")
	if b == null:
		push_warning("Comparing with null resource b!")
	
	if a == null or b == null:
		return []
	
	var differences := []
	if a.name != b.name:
		differences.append('name')
	if a.description != b.description:
		differences.append('description')
	if a.icon_path != b.icon_path:
		differences.append('icon_path')
	if a.maximum_progress != b.maximum_progress:
		differences.append('maximum_progress')
	if a.display_partial_progress != b.display_partial_progress:
		differences.append('display_partial_progress')
	if a.rarity != b.rarity:
		differences.append('rarity')
	return differences
