extends GutTest
## Unit tests for ChiefMintResource

func test_initialization():
	var resource = ChiefMintResource.new()
	assert_not_null(resource, "Resource should be created")
	assert_eq(resource.resource_name, "Chief Mint Resource", "Should have correct resource name")


func test_is_class_identifies_correctly():
	var resource = ChiefMintResource.new()
	assert_true(resource.is_class("ChiefMintResource"), "Should identify as ChiefMintResource")
	assert_true(resource.is_class("Resource"), "Should identify as Resource")


func test_can_store_definition():
	var resource = ChiefMintResource.new()
	var definition = ChiefMintDefinitionResource.new()
	definition.name = "Test Achievement"
	
	resource.definition = definition
	assert_not_null(resource.definition, "Should store definition")
	assert_eq(resource.definition.name, "Test Achievement", "Should correctly store definition")


func test_can_store_progress():
	var resource = ChiefMintResource.new()
	var progress = ChiefMintProgress.new()
	progress.current = 5
	progress.maximum = 10
	
	resource.progress = progress
	assert_not_null(resource.progress, "Should store progress")
	assert_eq(resource.progress.current, 5, "Should correctly store progress current")
	assert_eq(resource.progress.maximum, 10, "Should correctly store progress maximum")
