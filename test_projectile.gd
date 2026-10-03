extends SceneTree

var tests_passed = 0
var tests_failed = 0

func _initialize():
	print("Running tests for Projectile.gd...")

	test_movement()
	test_destroy_on_target_lost()
	test_hit_target_no_poison()
	test_hit_target_with_poison()
	test_hit_wrong_target()

	print("Tests complete. Passed: ", tests_passed, ", Failed: ", tests_failed)
	if tests_failed > 0:
		quit(1)
	else:
		quit(0)

func assert_true(condition: bool, test_name: String):
	if condition:
		tests_passed += 1
		print("PASS: ", test_name)
	else:
		tests_failed += 1
		print("FAIL: ", test_name)

func assert_false(condition: bool, test_name: String):
	if not condition:
		tests_passed += 1
		print("PASS: ", test_name)
	else:
		tests_failed += 1
		print("FAIL: ", test_name)

# --- Mocks ---

class MockHealthComponent extends Node:
	var damage_taken = 0.0
	var poison_ticks = 0
	var poison_dps = 0.0

	func _init():
		name = "HealthComponent"

	func take_damage(amount: float):
		damage_taken += amount

	func apply_poison(ticks: int, dps: float):
		poison_ticks = ticks
		poison_dps = dps

class MockProjectile extends Area3D:
	var queue_free_called = false

	# Instead of actual queue_free, we intercept it to test
	func queue_free():
		queue_free_called = true
		super.queue_free()

# --- Tests ---

func test_movement():
	var projectile = load("res://Scripts/Projectile.gd").new()
	var target = Node3D.new()

	root.add_child(projectile)
	root.add_child(target)

	projectile.target = target
	projectile.speed = 100.0
	projectile.global_position = Vector3(0, 0, 0)
	target.global_position = Vector3(10, 0, 0)

	var initial_distance = projectile.global_position.distance_to(target.global_position)
	projectile._physics_process(0.1)
	var new_distance = projectile.global_position.distance_to(target.global_position)

	assert_true(new_distance < initial_distance, "test_movement: Projectile should move towards target")

	projectile.free()
	target.free()

func test_destroy_on_target_lost():
	var ProjectileScript = load("res://Scripts/Projectile.gd")
	# We use a wrapper to spy on queue_free
	var projectile = MockProjectile.new()
	projectile.set_script(ProjectileScript)
	root.add_child(projectile)

	projectile.target = null
	projectile._physics_process(0.1)

	assert_true(projectile.queue_free_called, "test_destroy_on_target_lost: Projectile should free itself if target is null")
	# Projectile will be freed automatically at end of frame or we can free manually if it didn't
	if is_instance_valid(projectile):
		projectile.free()

func test_hit_target_no_poison():
	var ProjectileScript = load("res://Scripts/Projectile.gd")
	var projectile = MockProjectile.new()
	projectile.set_script(ProjectileScript)

	var target = Node3D.new()
	var health = MockHealthComponent.new()
	target.add_child(health)

	root.add_child(projectile)
	root.add_child(target)

	projectile.target = target
	projectile.damage = 25.0
	projectile.is_poisonous = false

	projectile._on_body_entered(target)

	assert_true(health.damage_taken == 25.0, "test_hit_target_no_poison: Target should take 25 damage")
	assert_true(health.poison_ticks == 0, "test_hit_target_no_poison: Target should not take poison")
	assert_true(projectile.queue_free_called, "test_hit_target_no_poison: Projectile should free itself after hit")

	target.free()
	if is_instance_valid(projectile):
		projectile.free()

func test_hit_target_with_poison():
	var ProjectileScript = load("res://Scripts/Projectile.gd")
	var projectile = MockProjectile.new()
	projectile.set_script(ProjectileScript)

	var target = Node3D.new()
	var health = MockHealthComponent.new()
	target.add_child(health)

	root.add_child(projectile)
	root.add_child(target)

	projectile.target = target
	projectile.damage = 20.0
	projectile.is_poisonous = true

	projectile._on_body_entered(target)

	assert_true(health.damage_taken == 20.0, "test_hit_target_with_poison: Target should take 20 damage")
	assert_true(health.poison_ticks == 4, "test_hit_target_with_poison: Target should take 4 poison ticks")
	assert_true(health.poison_dps == 10.0, "test_hit_target_with_poison: Target should take 10 poison dps")
	assert_true(projectile.queue_free_called, "test_hit_target_with_poison: Projectile should free itself after hit")

	target.free()
	if is_instance_valid(projectile):
		projectile.free()

func test_hit_wrong_target():
	var ProjectileScript = load("res://Scripts/Projectile.gd")
	var projectile = MockProjectile.new()
	projectile.set_script(ProjectileScript)

	var actual_target = Node3D.new()
	var wrong_target = Node3D.new()
	var health = MockHealthComponent.new()
	wrong_target.add_child(health)

	root.add_child(projectile)
	root.add_child(actual_target)
	root.add_child(wrong_target)

	projectile.target = actual_target
	projectile.damage = 25.0

	projectile._on_body_entered(wrong_target)

	assert_true(health.damage_taken == 0.0, "test_hit_wrong_target: Wrong target should not take damage")
	assert_false(projectile.queue_free_called, "test_hit_wrong_target: Projectile should not free itself")

	actual_target.free()
	wrong_target.free()
	if is_instance_valid(projectile):
		projectile.free()
