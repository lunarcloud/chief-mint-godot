class_name ChiefMintDefinitionResource, "res://addons/chief_mint/icon/icon.svg"
extends Resource
## Chief Mint Definition Resource
## Resource that contains the information for an achievement (but not it's current progress)

## Rarity Levels for a Mint
enum ChiefMintRarity { COMMON = 0, UNCOMMON = 1, RARE = 2, COMPLETION = 3 }

export var name: String

export var description: String

export var icon: Image

export(int, 1, 255, 1) var maximum_progress: int = 1

export var display_partial_progress: bool = true

export(int, "Common", "Uncommon", "Rare", "Completion") var rarity := ChiefMintRarity.COMMON


func _init():
	self.resource_name = "Chief Mint Definition Resource"


# Add support for is_class
func is_class(name: String) -> bool:
	return name == "ChiefMintDefinitionResource" or .is_class(name)


## Compare two mint instances, receive a list of the differences
static func differences(a: ChiefMintDefinitionResource, b: ChiefMintDefinitionResource) -> Array:
	if a == null:
		push_warning("Comparing with null resource a!")
	if b == null:
		push_warning("Comparing with null resource b!")

	if a == null or b == null:
		return []

	var differences := []
	if a.name != b.name:
		differences.append("name")
	if a.description != b.description:
		differences.append("description")
	if a.icon != b.icon:
		differences.append("icon")
	if a.maximum_progress != b.maximum_progress:
		differences.append("maximum_progress")
	if a.display_partial_progress != b.display_partial_progress:
		differences.append("display_partial_progress")
	if a.rarity != b.rarity:
		differences.append("rarity")
	return differences
