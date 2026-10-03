extends SceneTree

func _initialize():
    print("--- Starting Unit.gd Tests ---")
    var unit_script = load("res://Scripts/Unit.gd")

    var all_passed = true

    # Test 1: Initialization and attribute assignment
    var unit1 = unit_script.new()
    unit1.name = "ScrapTank"
    var mesh = MeshInstance3D.new()
    mesh.name = "MeshInstance3D"
    unit1.add_child(mesh)

    # Add to tree
    var temp_root = Node.new()
    root.add_child(temp_root)
    temp_root.add_child(unit1)

    if unit1.unit_attribute == "Mechanical":
        print("Test 1 Passed: Tank got Mechanical attribute")
    else:
        print("Test 1 Failed: Expected Mechanical, got " + str(unit1.unit_attribute))
        all_passed = false

    # Test 2: find_new_target() behavior
    var unit2 = unit_script.new()
    unit2.name = "OrganicDude"
    var mesh2 = MeshInstance3D.new()
    mesh2.name = "MeshInstance3D"
    unit2.add_child(mesh2)
    unit2.add_to_group("SideA")
    temp_root.add_child(unit2)

    var enemy = Node3D.new()
    enemy.add_to_group("Targetable")
    enemy.add_to_group("SideB")
    temp_root.add_child(enemy)

    unit2.find_new_target()
    if unit2.current_target == enemy:
        print("Test 2 Passed: Found enemy target")
    else:
        print("Test 2 Failed: Did not find enemy target")
        all_passed = false

    print("--- Tests Completed ---")

    if all_passed:
        quit(0)
    else:
        quit(1)
