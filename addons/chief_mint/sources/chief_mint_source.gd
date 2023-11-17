class_name ChiefMintSource
extends Node
## Chief Mint Source
## Base Class that Chief Mint sources must implement.


func get_source_name() -> String:
	return "none"


## Get the definitions
func load_defs() -> ChiefMintDefinitionsResource:
	return ChiefMintDefinitionsResource.new()


## Get all progress
func load_saved() -> ChiefMintSaveResource:
	return ChiefMintSaveResource.new()


## Reset progress (optional for source to implement)
func clear_all_progress() -> bool:
	return false


## Increment the progress of a mint
func increment_progress(_name: String) -> ChiefMintResource:
	return ChiefMintResource.new()


## Force the progress of a mint to a specific value (optional for source to implement)
func set_progress(_name: String, _value) -> ChiefMintResource:
	return ChiefMintResource.new()


## Get whether the mint is considered achieved
func is_complete(_name: String) -> bool:
	return false


## Get the progress towards the completion of a mint
func get_progress(_name: String) -> ChiefMintProgress:
	return ChiefMintProgress.new()
