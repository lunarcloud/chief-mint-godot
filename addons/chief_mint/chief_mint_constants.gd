class_name ChiefMintConstants
## Chief Mint Plugin Constants
## Constant variables used in the plugin

## Enum values for the "Source" project setting dropdown
enum SourceType { OFFLINE_FILE, GODOT_STEAM, OTHER }

const MINT_DEFINITION_SETTING := "chief_mint/editor/definitions"
const MINT_DEFINITION_DEFAULT := "res://chiefmints.tres"

const MINT_SOURCE_TYPE_SETTING := "chief_mint/source/source"
const MINT_SOURCE_TYPE_HINT_STRING := "Offline File,GodotSteam,Other"
const MINT_SOURCE_TYPE_DEFAULT := SourceType.OFFLINE_FILE

const MINT_SOURCE_OTHER_SETTING := "chief_mint/source/other_source_script"
const MINT_SOURCE_OTHER_DEFAULT := ""

const MINT_SOURCE_FILE_SCRIPT := "res://addons/chief_mint/sources/chief_mint_source_file.gd"
const MINT_SOURCE_STEAM_SCRIPT := "res://addons/chief_mint/sources/chief_mint_source_steam.gd"

## Kept for backwards compatibility (default source implementation)
const MINT_SOURCE_DEFAULT := MINT_SOURCE_FILE_SCRIPT

const MINT_SOURCE_LOCAL_PATH_SETTING := "chief_mint/source/local_source_location"
const MINT_SOURCE_LOCAL_PATH_DEFAULT := "user://chiefmints.res"
