extends GutTest
## Unit tests for ChiefMintProgress


func test_is_complete_when_current_equals_maximum():
	var progress = ChiefMintProgress.new()
	progress.current = 5
	progress.maximum = 5
	assert_true(progress.is_complete(), "Should be complete when current equals maximum")


func test_is_complete_when_current_exceeds_maximum():
	var progress = ChiefMintProgress.new()
	progress.current = 10
	progress.maximum = 5
	assert_true(progress.is_complete(), "Should be complete when current exceeds maximum")


func test_is_not_complete_when_current_less_than_maximum():
	var progress = ChiefMintProgress.new()
	progress.current = 3
	progress.maximum = 5
	assert_false(progress.is_complete(), "Should not be complete when current is less than maximum")


func test_is_not_complete_when_current_is_zero():
	var progress = ChiefMintProgress.new()
	progress.current = 0
	progress.maximum = 5
	assert_false(progress.is_complete(), "Should not be complete when current is zero")


func test_initialization():
	var progress = ChiefMintProgress.new()
	assert_not_null(progress, "Progress should be created")
	assert_eq(
		progress.resource_name, "Chief Mint Progress Resource", "Should have correct resource name"
	)


func test_is_class_identifies_correctly():
	var progress = ChiefMintProgress.new()
	assert_true(
		progress.is_class("ChiefMintProgressResource"),
		"Should identify as ChiefMintProgressResource"
	)
	assert_true(progress.is_class("Resource"), "Should identify as Resource")
