extends SceneTree

func _init():
	print("Running HealthComponent tests...")

	var parent_node = Node.new()
	parent_node.name = "DummyTarget"

	var health_component = load("res://Scripts/HealthComponent.gd").new()
	parent_node.add_child(health_component)

	# We don't call _ready() to avoid UI instantiation since we're headless
	# Instead we initialize what we need for the test
	health_component.max_health = 100.0
	health_component.current_health = 100.0

	var all_passed = true

	print("Test 1: Take positive damage")
	# We can call sync_take_damage directly
	health_component.sync_take_damage(20.0)
	if health_component.current_health == 80.0:
		print("Test 1 Passed")
	else:
		print("Test 1 Failed: Expected 80.0, got ", health_component.current_health)
		all_passed = false

	print("Test 2: Take negative damage (should not heal)")
	health_component.sync_take_damage(-30.0)
	if health_component.current_health == 80.0:
		print("Test 2 Passed")
	else:
		print("Test 2 Failed: Expected 80.0, got ", health_component.current_health)
		all_passed = false

	print("Test 3: Take 0 damage")
	health_component.sync_take_damage(0.0)
	if health_component.current_health == 80.0:
		print("Test 3 Passed")
	else:
		print("Test 3 Failed: Expected 80.0, got ", health_component.current_health)
		all_passed = false

	print("All tests finished.")
	if all_passed:
		quit()
	else:
		quit(1)
