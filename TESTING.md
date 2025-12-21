# Chief Mint Unit Testing Guide

This project uses **GUT (Godot Unit Test)** framework for unit testing. GUT is the most popular and widely-used testing framework for Godot Engine.

## About GUT

GUT (Godot Unit Test) is a comprehensive testing framework that allows you to write unit tests and integration tests for your Godot projects using GDScript. For more information, visit the [GUT documentation](https://gut.readthedocs.io/).

## Setup

The GUT framework is already included in the `addons/gut/` directory. To enable it:

1. Open the project in Godot Editor
2. Go to Project → Project Settings → Plugins
3. Enable the "Gut" plugin if it's not already enabled

## Running Tests

### From the Godot Editor

1. Open the Godot Editor
2. Click on the "GUT" panel at the bottom of the editor (appears when the plugin is enabled)
3. Click "Run All" to run all tests, or select specific test files to run

### From Command Line

You can run tests headlessly from the command line. This is a 2-step process:

**Step 1: Import the project** (required on first run or after adding new files)
```bash
godot --path . --headless --import
```

**Step 2: Run the tests**
```bash
godot --path . --headless -s addons/gut/gut_cmdln.gd
```

This will:
- Run all tests in the `test/` directory
- Output results to the console
- Exit with a non-zero code if tests fail (useful for CI/CD)

### Configuration

Test configuration is defined in `.gutconfig.json`:

```json
{
  "dirs": ["res://test/"],
  "include_subdirs": true,
  "prefix": "test_",
  "suffix": ".gd",
  "log_level": 1,
  "should_exit": true,
  "should_exit_on_success": true
}
```

## Test Structure

All test files are located in the `test/` directory. Each test file:
- Extends `GutTest`
- Has a filename starting with `test_`
- Contains test methods starting with `test_`

### Test Files

- **test_chief_mint_progress.gd** - Tests for the ChiefMintProgress resource
- **test_chief_mint_definition.gd** - Tests for the ChiefMintDefinitionResource
- **test_chief_mint_resource.gd** - Tests for the ChiefMintResource
- **test_chief_mint_definitions_resource.gd** - Tests for the ChiefMintDefinitionsResource
- **test_chief_mint_save_resource.gd** - Tests for the ChiefMintSaveResource
- **test_chief_mint_source.gd** - Tests for the base ChiefMintSource class
- **test_chief_mint_source_file.gd** - Tests for the ChiefMintSourceFile implementation
- **test_chief_mint_singleton.gd** - Tests for the ChiefMintSingleton

## Test Coverage

The test suite covers:

### Resource Classes
- ✅ ChiefMintProgress - Progress tracking and completion logic
- ✅ ChiefMintDefinitionResource - Achievement definitions and comparison
- ✅ ChiefMintResource - Combined definition and progress
- ✅ ChiefMintDefinitionsResource - Collection of definitions
- ✅ ChiefMintSaveResource - Saved achievement state

### Source Classes
- ✅ ChiefMintSource - Base class interface
- ✅ ChiefMintSourceFile - Local file storage implementation
  - Loading and saving achievements
  - Progress increment and setting
  - Completion detection
  - Completion achievement auto-unlock

### Core Classes
- ✅ ChiefMintSingleton - Main achievement manager
  - Progress tracking
  - Signal emission
  - Source integration
  - Achievement completion

## Writing New Tests

To add new tests:

1. Create a new file in the `test/` directory starting with `test_`
2. Extend `GutTest`
3. Add test methods starting with `test_`

Example:

```gdscript
extends GutTest

func test_something():
    var result = some_function()
    assert_eq(result, expected_value, "Should return expected value")
```

### Common GUT Assertions

- `assert_true(value, message)` - Assert value is true
- `assert_false(value, message)` - Assert value is false
- `assert_eq(actual, expected, message)` - Assert equality
- `assert_ne(actual, expected, message)` - Assert inequality
- `assert_null(value, message)` - Assert value is null
- `assert_not_null(value, message)` - Assert value is not null
- `assert_has(container, item, message)` - Assert container has item
- `assert_signal_emitted(object, signal_name, message)` - Assert signal was emitted

### Setup and Teardown

Use `before_each()` and `after_each()` methods for setup and cleanup:

```gdscript
extends GutTest

var test_object

func before_each():
    test_object = MyClass.new()

func after_each():
    test_object.free()

func test_something():
    # Your test here
    pass
```

## Best Practices

1. **Keep tests focused** - Each test should test one specific behavior
2. **Use descriptive names** - Test names should clearly describe what they're testing
3. **Clean up resources** - Use `after_each()` to clean up test files and objects
4. **Test edge cases** - Include tests for boundary conditions and error cases
5. **Watch signals** - Use `watch_signals()` to test signal emission
6. **Isolate tests** - Tests should not depend on each other or run in a specific order

## Continuous Integration

To integrate tests with CI/CD:

```yaml
# Example GitHub Actions workflow
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v2
    - name: Download Godot
      run: |
        wget https://downloads.tuxfamily.org/godotengine/4.5/Godot_v4.5-stable_linux.x86_64.zip
        unzip Godot_v4.5-stable_linux.x86_64.zip
    - name: Import Project
      run: |
        ./Godot_v4.5-stable_linux.x86_64 --path . --headless --import
    - name: Run Tests
      run: |
        ./Godot_v4.5-stable_linux.x86_64 --path . --headless -s addons/gut/gut_cmdln.gd
```

## Troubleshooting

### Tests won't run
- Ensure the GUT plugin is enabled in Project Settings
- Check that test files are in the `test/` directory
- Verify test files start with `test_` prefix
- Check that test methods start with `test_` prefix

### File access errors in tests
- Tests use `user://` paths for temporary files
- Ensure proper cleanup in `after_each()` methods
- Check file permissions

### Signal tests failing
- Make sure to call `watch_signals(object)` before the action that emits the signal
- Signals must be emitted during the same test method as the assertion

## Additional Resources

- [GUT Documentation](https://gut.readthedocs.io/)
- [GUT GitHub Repository](https://github.com/bitwes/Gut)
- [Godot Unit Testing Best Practices](https://docs.godotengine.org/en/stable/tutorials/scripting/unit_testing.html)
