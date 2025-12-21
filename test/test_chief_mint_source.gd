extends GutTest
## Unit tests for ChiefMintSource base class

var source: ChiefMintSource


func before_each():
	source = ChiefMintSource.new()


func test_get_source_name_returns_none():
	assert_eq(source.get_source_name(), "none", "Base class should return 'none'")


func test_load_defs_returns_empty_definitions():
	var defs = source.load_defs()
	assert_not_null(defs, "Should return a definitions resource")
	assert_true(defs is ChiefMintDefinitionsResource, "Should return ChiefMintDefinitionsResource")


func test_load_saved_returns_empty_save():
	var save = source.load_saved()
	assert_not_null(save, "Should return a save resource")
	assert_true(save is ChiefMintSaveResource, "Should return ChiefMintSaveResource")


func test_clear_all_progress_returns_false():
	var result = source.clear_all_progress()
	assert_false(result, "Base class should return false")


func test_increment_progress_returns_empty_resource():
	var mint = source.increment_progress("Test Achievement")
	assert_not_null(mint, "Should return a mint resource")
	assert_true(mint is ChiefMintResource, "Should return ChiefMintResource")


func test_set_progress_returns_empty_resource():
	var mint = source.set_progress("Test Achievement", 5)
	assert_not_null(mint, "Should return a mint resource")
	assert_true(mint is ChiefMintResource, "Should return ChiefMintResource")


func test_is_complete_returns_false():
	var result = source.is_complete("Test Achievement")
	assert_false(result, "Base class should return false")


func test_get_progress_returns_empty_progress():
	var progress = source.get_progress("Test Achievement")
	assert_not_null(progress, "Should return a progress resource")
	assert_true(progress is ChiefMintProgress, "Should return ChiefMintProgress")


func test_has_completion_achievement_unlocked_signal():
	assert_has_signal(source, "completion_achievement_unlocked", 
		"Should have completion_achievement_unlocked signal")
