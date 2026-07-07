extends GutTest
## Unit tests for ChiefMintSourceSteam
##
## These tests run in an environment without the GodotSteam extension installed, so they focus on
## verifying the source degrades gracefully (no-ops / null / false) rather than crashing when the
## "Steam" engine singleton isn't available. Real Steam achievement/stat behavior should be
## verified manually in a build with GodotSteam + an initialized Steam app.

var source: ChiefMintSourceSteam
var test_def_path: String


func before_each():
	var random_suffix = str(Time.get_ticks_msec())
	test_def_path = "user://test_steam_source_defs_%s.tres" % random_suffix

	if FileAccess.file_exists(test_def_path):
		DirAccess.remove_absolute(test_def_path)

	var defs = ChiefMintDefinitionsResource.new()

	var def1 = ChiefMintDefinitionResource.new()
	def1.name = "First Achievement"
	def1.description = "Complete the first task"
	def1.maximum_progress = 10
	def1.rarity = ChiefMintDefinitionResource.ChiefMintRarity.COMMON

	var def2 = ChiefMintDefinitionResource.new()
	def2.name = "Second Achievement"
	def2.description = "Complete the second task"
	def2.maximum_progress = 1
	def2.rarity = ChiefMintDefinitionResource.ChiefMintRarity.UNCOMMON

	var def3 = ChiefMintDefinitionResource.new()
	def3.name = "Completion Achievement"
	def3.description = "Complete all achievements"
	def3.maximum_progress = 1
	def3.rarity = ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION

	var defs_array: Array[Resource] = []
	defs_array.append(def1)
	defs_array.append(def2)
	defs_array.append(def3)
	defs.definitions = defs_array

	ResourceSaver.save(defs, test_def_path)

	ProjectSettings.set_setting(ChiefMintConstants.MINT_DEFINITION_SETTING, test_def_path)

	source = ChiefMintSourceSteam.new()
	add_child_autofree(source)


func after_each():
	if FileAccess.file_exists(test_def_path):
		DirAccess.remove_absolute(test_def_path)

	ProjectSettings.set_setting(ChiefMintConstants.MINT_DEFINITION_SETTING, null)


func test_get_source_name():
	assert_eq(source.get_source_name(), "steam", "Should return 'steam' as source name")


func test_load_defs():
	var defs = source.load_defs()
	assert_not_null(defs, "Should load definitions")
	assert_eq(defs.definitions.size(), 3, "Should have 3 definitions")
	assert_eq(
		defs.definitions[0].name, "First Achievement", "Should load first definition correctly"
	)


func test_load_saved_without_steam_singleton():
	# Without the GodotSteam extension installed, Steam won't be available as an engine
	# singleton, so this should not crash and should return defaulted progress.
	var save = source.load_saved()
	assert_not_null(save, "Should still return a save resource")
	assert_eq(save.mints.size(), 3, "Should have 3 mints built from definitions")


func test_get_progress_for_nonexistent_achievement():
	var progress = source.get_progress("Nonexistent Achievement")
	assert_null(progress, "Should return null for nonexistent achievement")


func test_get_progress_without_steam_singleton():
	var progress = source.get_progress("First Achievement")
	assert_not_null(progress, "Should still return a progress resource")
	assert_eq(progress.maximum, 10, "Maximum should come from the local definition")
	assert_eq(progress.current, 0, "Current should default to 0 without Steam available")


func test_is_complete_false_without_steam_singleton():
	assert_false(
		source.is_complete("First Achievement"), "Should not be complete without Steam available"
	)


func test_clear_all_progress_without_steam_singleton():
	assert_false(
		source.clear_all_progress(), "Should return false when Steam singleton isn't available"
	)


func test_increment_progress_unknown_achievement_returns_null():
	var mint = source.increment_progress("Nonexistent Achievement")
	assert_null(mint, "Should return null for an unknown mint name")


func test_set_progress_unknown_achievement_returns_null():
	var mint = source.set_progress("Nonexistent Achievement", 5)
	assert_null(mint, "Should return null for an unknown mint name")


func test_increment_progress_without_steam_singleton_does_not_crash():
	var mint = source.increment_progress("First Achievement")
	assert_not_null(mint, "Should still return a mint resource for a known definition")
	assert_eq(mint.definition.name, "First Achievement", "Should be for the requested mint")


func test_set_progress_without_steam_singleton_does_not_crash():
	var mint = source.set_progress("First Achievement", 5)
	assert_not_null(mint, "Should still return a mint resource for a known definition")
	assert_eq(mint.definition.name, "First Achievement", "Should be for the requested mint")
