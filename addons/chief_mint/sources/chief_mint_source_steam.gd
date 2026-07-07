class_name ChiefMintSourceSteam
extends ChiefMintSource
## Mint Source: Steam
## Chief Mint Source that uses GodotSteam (https://codeberg.org/godotsteam/godotsteam) achievements
## and stats as the backing store for mint progress. Steam itself is treated as the source of
## truth for unlock state and progress, instead of a local save file.
##
## Requirements / setup:
## - The GodotSteam GDExtension must be installed, which registers a "Steam" engine singleton as
##   soon as the extension loads (this happens automatically, before any autoloads run).
## - Steam itself must be initialized before this source is created. The "Steam" singleton
##   existing does NOT mean Steam has been initialized. The simplest way to handle this (no
##   custom autoload code needed) is GodotSteam's own built-in auto-initialization, available
##   since GodotSteam 3.29 / 4.14 under Project Settings > Steam > Initialization - set your App
##   ID there and enable "Auto Initialize", and GodotSteam will initialize Steam for you before
##   any autoload's _ready() runs, including ChiefMint's. If you instead initialize Steam manually
##   (e.g. calling Steam.steamInitEx() from your own autoload), that autoload MUST be listed
##   ABOVE "ChiefMint" in Project Settings > Autoload, so it runs first.
## - Each ChiefMintDefinitionResource.name must exactly match the "API Name" of an achievement
##   configured in the Steamworks App Admin panel.
## - For mints with maximum_progress greater than 1, also create an integer Stat in the
##   Steamworks App Admin panel using that same API Name, so progress can be tracked and surfaced
##   to the player via indicateAchievementProgress().
##
## Note: this source has not been tested against a real Steamworks app.
## It should degrade gracefully (no-ops / returns false or null) whenever the "Steam" singleton
## isn't present or Steam hasn't been successfully initialized, so it's safe to use outside of a
## Steam build, but please verify achievement/stat behavior against your own App Admin
## configuration.

var def_path

## The GodotSteam singleton, fetched dynamically so this script doesn't hard-depend on the
## GodotSteam extension being installed (it may not be, for projects that don't target Steam).
var _steam: Object = null

## Whether Steam has actually been initialized (not just whether the extension is loaded).
var _steam_ready: bool = false


func _init():
	def_path = ProjectSettings.get_setting(ChiefMintConstants.MINT_DEFINITION_SETTING)
	if def_path == null:
		def_path = ChiefMintConstants.MINT_DEFINITION_DEFAULT

	if not Engine.has_singleton("Steam"):
		push_warning(
			(
				"ChiefMintSourceSteam: 'Steam' engine singleton not found. Install/enable the "
				+ "GodotSteam extension. Falling back to no-op behavior."
			)
		)
		return

	_steam = Engine.get_singleton("Steam")

	# Older Steamworks SDKs (pre-1.60 / GodotSteam pre-3.26/4.9) require this before any
	# stat/achievement getters or setters are used. Newer versions removed it, so only call it
	# if it's actually present.
	if _steam.has_method("requestCurrentStats"):
		_steam.call("requestCurrentStats")

	# The singleton existing only means the extension is loaded, not that Steam has been
	# initialized. GodotSteam's own "auto-initialize" project setting (Steam > Initialization,
	# GodotSteam 3.29 / 4.14+) or a manual Steam.steamInitEx() call handles that; either way,
	# isSteamRunning() is only meaningful *after* a successful init, so use it as a best-effort
	# readiness check here.
	if _steam.has_method("isSteamRunning"):
		_steam_ready = _steam.call("isSteamRunning")
		if not _steam_ready:
			push_warning(
				(
					"ChiefMintSourceSteam: 'Steam' singleton found, but Steam does not appear to "
					+ "be initialized/running yet. Enable GodotSteam's built-in "
					+ "'Auto Initialize' setting under Project Settings > Steam > "
					+ "Initialization, or make sure whatever autoload calls "
					+ "Steam.steamInitEx() manually is listed ABOVE 'ChiefMint' in Project "
					+ "Settings > Autoload, so it runs first. Falling back to no-op behavior."
				)
			)
	else:
		# Older GodotSteam versions may not expose isSteamRunning(); assume ready since we can't
		# verify otherwise.
		_steam_ready = true


func get_source_name() -> String:
	return "steam"


## Get the definitions (still loaded locally, same as ChiefMintSourceFile - Steam only stores
## progress/unlock state, not icons/descriptions/etc.)
func load_defs() -> ChiefMintDefinitionsResource:
	if def_path == null or not ResourceLoader.exists(def_path):
		return ChiefMintDefinitionsResource.new()
	return load(def_path) as ChiefMintDefinitionsResource


## Build a fresh save snapshot by reading current values straight out of Steam.
func load_saved() -> ChiefMintSaveResource:
	var data := ChiefMintSaveResource.new()
	for def in load_defs().definitions:
		if def == null:
			continue
		data.mints.append(_build_mint(def))
	return data


## Reset progress via Steam's own testing helper. Only intended for development use.
func clear_all_progress() -> bool:
	if not _is_ready():
		return false
	_steam.call("resetAllStats", true)
	return true


func increment_progress(name: String) -> ChiefMintResource:
	var def = _find_definition(name)
	if def == null:
		push_warning("ChiefMintSourceSteam: No definition found for mint '%s'" % name)
		return null

	if not _is_ready():
		return _build_mint(def)

	if def.maximum_progress <= 1:
		return set_progress(name, 1)

	var current: int = _steam.call("getStatInt", name)
	return set_progress(name, current + 1)


func set_progress(name: String, value) -> ChiefMintResource:
	var def = _find_definition(name)
	if def == null:
		push_warning("ChiefMintSourceSteam: No definition found for mint '%s'" % name)
		return null

	if not _is_ready():
		return _build_mint(def)

	if def.maximum_progress <= 1:
		if int(value) >= 1:
			_steam.call("setAchievement", name)
		else:
			_steam.call("clearAchievement", name)
	else:
		var clamped: int = clampi(int(value), 0, def.maximum_progress)
		_steam.call("setStatInt", name, clamped)
		if clamped >= def.maximum_progress:
			_steam.call("setAchievement", name)
		else:
			_steam.call("indicateAchievementProgress", name, clamped, def.maximum_progress)

	_store_stats()
	_check_completion_achievements()
	return _build_mint(def)


func is_complete(name: String) -> bool:
	if not _is_ready():
		return false
	var result: Dictionary = _steam.call("getAchievement", name)
	return result.get("ret", false) and result.get("achieved", false)


func get_progress(name: String) -> ChiefMintProgress:
	var def = _find_definition(name)
	if def == null:
		return null

	var progress := ChiefMintProgress.new()
	progress.maximum = def.maximum_progress

	if not _is_ready():
		progress.current = 0
		return progress

	if def.maximum_progress <= 1:
		progress.current = 1 if is_complete(name) else 0
	else:
		progress.current = clampi(int(_steam.call("getStatInt", name)), 0, def.maximum_progress)

	return progress


func _is_ready() -> bool:
	return _steam != null and _steam_ready


func _find_definition(name: String):
	for def in load_defs().definitions:
		if def != null and def.name == name:
			return def
	return null


func _build_mint(def) -> ChiefMintResource:
	var mint := ChiefMintResource.new()
	mint.definition = def
	mint.progress = get_progress(def.name)
	return mint


func _store_stats() -> void:
	if _is_ready():
		_steam.call("storeStats")


## Check if all non-completion achievements are complete and trigger the completion achievement,
## mirroring the behavior of ChiefMintSourceFile.
func _check_completion_achievements() -> void:
	if not _is_ready():
		return

	var completion_def = null
	var non_completion_defs := []

	for def in load_defs().definitions:
		if def == null:
			continue
		if def.rarity == ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION:
			completion_def = def
		else:
			non_completion_defs.append(def)

	if completion_def == null:
		return

	var all_complete := true
	for def in non_completion_defs:
		if not is_complete(def.name):
			all_complete = false
			break

	if all_complete and not is_complete(completion_def.name):
		_steam.call("setAchievement", completion_def.name)
		_store_stats()
		completion_achievement_unlocked.emit(_build_mint(completion_def))
