lu = require('externals/luaunit/luaunit')
require("Triumph_TTS/assets/assets")
require('scripts/data/data_settings')
require('scripts/data/data_tables')
require('scripts/data/data_terrain')
require('scripts/data/data_troops_plain_tiles')
require('scripts/data/data_troops')
require('scripts/base_cache')
require('scripts/log')
require('scripts/utilities_lua')
require('scripts/utilities')
require('scripts/logic_base_obj')
require('scripts/logic_terrain')
require('scripts/logic_gizmos')
require('scripts/logic_spawn_army')
require('scripts/logic_dead')
require('scripts/logic_dice')
require('scripts/logic_history_stack')
require('scripts/logic')
require('scripts/uievents')


print_error = function(message)
	print(message)
	assert(false)
end

-- disable history since we do not want to use startLuaCoroutine
history_record_snapshot = function() end
history_record_delta_snapshot = function() end

lu.assertPointEquals = function(a,b)
  lu.assertEquals(a['x'], b['x'])
  lu.assertEquals(a['y'], b['y'])
  lu.assertEquals(a['z'], b['z'])
end

lu.assertPointAlmostEquals = function(a,b)
  lu.assertAlmostEquals(a['x'], b['x'], 0.01)
  lu.assertAlmostEquals(a['y'], b['y'], 0.01)
  lu.assertAlmostEquals(a['z'], b['z'], 0.01)
end

lu.assertBaseEquals = function(a,b)
  lu.assertPointEquals(a.getRotation(), b.getRotation())
  lu.assertPointEquals(a.getPosition(), b.getPosition())
end

log = function(...)
  -- stub out for testing
end

print_info = function(...)
  -- stub out for testing
end

-- Create a fake base that can be used for
-- testing
function build_base(base_name, tile)
  if tile == nil then
    tile="tile_plain_Archers"
  end

  local base = {
    name=base_name,
    position={
      x=1.0057,
      y=1.2244,
      z=2.1356
    },
    rotation={
      x=0,
      y=0,
      z=0
    },
  }

  base['setName'] = function(new_name)
    base.name = new_name
  end

  base['getName']=function()
    return base.name
  end

  base['getPosition']=function()
    return base.position
  end

  base['setPosition']=function(new_value)
    base.position = new_value
  end

  base['getRotation']=function()
    return deep_copy(base.rotation)
  end

  base['setRotation']=function(new_value)
    if nil == new_value.x then
      base.rotation['x'] = new_value[1]
      base.rotation['y'] = new_value[2]
      base.rotation['z'] = new_value[3]
    else
      base.rotation = new_value
    end
  end

  base['getGUID'] = function()
    return "FAKEGUID"
  end

  g_bases[ base_name] = {
    tile=tile,
    is_red_player=true
  }

  return base
end

-- slightly disturb the base position and rotation so we can
-- check that snapping works.
function jiggle(base)
  local position = base.getPosition()
  position['x'] = position['x'] + 0.15
  position['x'] = position['z'] + 0.2
  base.setPosition(position)

  local rotation = base.getRotation()
  rotation['y'] = rotation['y'] + 5
  base.setRotation(rotation)
end


function test_turn_around_base()
  local moving_base = build_base("base 4Bw # 16")
  local before = calculate_transform(moving_base)
  turn_around_base(moving_base)
  local after = calculate_transform(moving_base)

  local expected_corner = before['corners']['topleft']
  local actual_corner = after['corners']['botright']
  lu.assertAlmostEquals(actual_corner['x'], expected_corner['x'], 0.01)
  lu.assertAlmostEquals(actual_corner['z'], expected_corner['z'], 0.01)
end

function test_calculate_transform_keeps_rotation_between_zero_and_two_pi_negative_degrees()
  local base = build_base("base WWg # 19", 'tile_plain_War_Wagons')
  base.setRotation({0, -90, 0})
  local t = calculate_transform(base)
  local actual= t.rotation
  lu.assertTrue(0 <= actual)
  lu.assertTrue(actual < (2*math.pi))
end

function test_calculate_transform_keeps_rotation_between_zero_and_two_pi_large_positive_degrees()
  local base = build_base("base WWg # 19", 'tile_plain_War_Wagons')
  base.setRotation({0,  90 + 720, 0 })
  local t = calculate_transform(base)
  local actual= t.rotation
  lu.assertTrue(0 <= actual)
  lu.assertTrue(actual < (2*math.pi))
end

function test_rotate_CCW_90()
  lu.assertNotNil(tile_plain_War_Wagons)
  local moving_base = build_base("base WWg # 19", 'tile_plain_War_Wagons')
  local before = calculate_transform(moving_base)
  moving_base.setRotation({0, -90, 0})
  local after = calculate_transform(moving_base)

  local expected_corner = before['corners']['topleft']
  local actual_corner = after['corners']['topright']
  lu.assertAlmostEquals(actual_corner['x'], expected_corner['x'], 0.01)
  lu.assertAlmostEquals(actual_corner['z'], expected_corner['z'], 0.01)
end



function test_distance_points_flat_sq()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediatly behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  local distance_moved = base_depth
  moving_base.position['z'] = resting_base.position['z'] - distance_moved
  transform_resting = calculate_transform(resting_base)
  transform_moving = calculate_transform(moving_base)
  local corners_resting = transform_resting['corners']
  local corners_moving = transform_moving['corners']

  lu.assertAlmostEquals(distance_points_flat_sq(
    corners_moving['topright'],corners_resting['botright']),
    0, 1e-4)
  lu.assertAlmostEquals(distance_points_flat_sq(
    corners_moving['topright'],corners_resting['topright']),
    distance_moved^2, 1e-4)
  end

function test_distance_front_to_back()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  moving_base.position['z'] = resting_base.position['z'] - base_depth
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_front_to_back(transform_moving, transform_resting)
  -- max distance between the front and back corners
  lu.assertAlmostEquals(actual, 0, 1e-4)
end

function test_is_behind()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  moving_base.position['z'] = resting_base.position['z'] - base_depth
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = is_behind(transform_moving, transform_resting)
  lu.assertTrue(actual)
end

function test_distance_back_to_front()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  moving_base.position['z'] = resting_base.position['z'] + base_depth
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- front and back bases edges are touching
  local actual = distance_back_to_front(transform_moving, transform_resting)
  -- max distance between the front and back corners
  lu.assertAlmostEquals(actual, 0, 1e-4)
end

function test_is_infront()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  moving_base.position['z'] = resting_base.position['z'] + base_depth
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- front and back bases edges are touching

  local actual = is_infront(transform_moving, transform_resting)
  lu.assertTrue(actual)
end


function test_distance_front_to_back_returns_furthest_distance()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be behind the resting base, but skewed
  -- with one corner within the threshold and one corner more than the
  -- threshold
  moving_base.position = shallow_copy(resting_base.position)
  moving_base.setRotation({0,  g_max_angle_pushback_rad, 0})

  local base_depth = get_size(resting_base.getName())['z']
  local threshold = (g_max_corner_distance_snap^0.5)
  moving_base.position['z'] = resting_base.position['z'] - (base_depth + threshold)
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_front_to_back(transform_moving, transform_resting)
  lu.assertFalse(actual > threshold)
end

function test_distance_right_to_left_side()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately beside the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_width = get_size(resting_base.getName())['x']
  moving_base.position['x'] = resting_base.position['x'] - base_width
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- left and right bases edges are touching
  local actual = distance_right_to_left_side(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0, 1e-4)
end

function test_is_left_side()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately beside the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_width = get_size(resting_base.getName())['x']
  moving_base.position['x'] = resting_base.position['x'] - base_width
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- left and right bases edges are touching
  local actual = is_left_side(transform_moving, transform_resting)
  lu.assertTrue(actual)
end

function test_distance_left_to_right_side()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately beside the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_width = get_size(resting_base.getName())['x']
  moving_base.position['x'] = resting_base.position['x'] + base_width
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- right and left bases edges are the touching
  local actual = distance_left_to_right_side(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0, 1e-4)
end

function test_is_right_side()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately beside the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_width = get_size(resting_base.getName())['x']
  moving_base.position['x'] = resting_base.position['x'] + base_width
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- right and left bases edges are the touching
  local actual = is_right_side(transform_moving, transform_resting)
  lu.assertTrue(actual)
end

function test_is_right_side()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately beside the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_width = get_size(resting_base.getName())['x']
  moving_base.position['x'] = resting_base.position['x'] + base_width
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- right and left bases edges are the touching
  local actual = is_right_side(transform_moving, transform_resting)
  lu.assertTrue(actual)
end


function test_distance_back_to_front_returns_huge_when_angle_too_different()
  local resting_base = build_base("base Bw # 19")
  local transform_resting = calculate_transform(resting_base)

  local moving_base = build_base("base WWg # 20", 'tile_plain_War_Wagons')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.botleft.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.botleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x
  moving_base.position['z'] = moving_base.position['z'] + delta_z
  moving_base.setRotation({0, -90, 0})
  transform_moving = calculate_transform(moving_base)

  local actual = distance_back_to_front(transform_moving, transform_resting)
  lu.assertEquals(actual, math.huge)
end

function test_distance_back_to_front_returns_distance()
  local resting_base = build_base("base Bw # 19")
  local transform_resting = calculate_transform(resting_base)

  local moving_base = build_base("base WWg # 20", 'tile_plain_War_Wagons')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.botleft.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.botleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x
  moving_base.position['z'] = moving_base.position['z'] + delta_z
  transform_moving = calculate_transform(moving_base)

  local actual = distance_back_to_front(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0.0, 1e-4)
end

function test_snap_to_base_infront()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)

  local moving_base = build_base("base WWg # 20", 'tile_plain_War_Wagons')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.botleft.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.botleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x
  moving_base.position['z'] = moving_base.position['z'] + delta_z
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)

  -- check that rule applies
  local actual = distance_back_to_front(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)

  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'infront')

  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, transform_resting.rotation, 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.botleft, transform_resting.corners.topleft)
  lu.assertPointAlmostEquals(transform_actual.corners.botright, transform_resting.corners.topright)
  lu.assertBaseEquals(resting_base, original_base)
end

function test_snap_to_base_behind()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  resting_base.setRotation({0, 0, 0})
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)

  local moving_base = build_base("base WWg # 20", 'tile_plain_War_Wagons')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.botleft.x - transform_moving.corners.topleft.x
  local delta_z = transform_resting.corners.botleft.z - transform_moving.corners.topleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x
  moving_base.position['z'] = moving_base.position['z'] + delta_z
  moving_base.setRotation({0, 0, 0})
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)

  -- check that rule applies
  local actual = distance_front_to_back(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)

  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'behind')

  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, transform_resting.rotation, 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topleft, transform_resting.corners.botleft)
  lu.assertPointAlmostEquals(transform_actual.corners.topright, transform_resting.corners.botright)
  lu.assertBaseEquals(resting_base, original_base)
end


function test_snap_to_base_opposite()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)

  local moving_base = build_base("base WWg # 20", 'tile_plain_War_Wagons')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x
  moving_base.position['z'] = moving_base.position['z'] + delta_z
  moving_base.setRotation({0, 180, 0})
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)

  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'opposite')

  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, normalize_radians(transform_resting.rotation+math.pi), 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topleft, transform_resting.corners.topright)
  lu.assertPointAlmostEquals(transform_actual.corners.topright, transform_resting.corners.topleft)
  lu.assertBaseEquals(resting_base, original_base)
end

function test_snap_to_base_left()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)

  local moving_base = build_base("base WWg # 20", 'tile_plain_War_Wagons')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x
  moving_base.position['z'] = moving_base.position['z'] + delta_z
  moving_base.setRotation({0, 0, 0})
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)

  -- check that rule applies
  local actual = distance_left_to_right_side(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)

  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'left')

  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, transform_resting.rotation, 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topright, transform_resting.corners.topleft)
  lu.assertBaseEquals(resting_base, original_base)
end


function test_snap_to_base_right()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)

  local moving_base = build_base("base WWg # 20", 'tile_plain_War_Wagons')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topright.x - transform_moving.corners.topleft.x
  local delta_z = transform_resting.corners.topright.z - transform_moving.corners.topleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x
  moving_base.position['z'] = moving_base.position['z'] + delta_z
  moving_base.setRotation({0, 0, 0})
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)

  -- check that rule applies
  local actual = distance_right_to_left_side(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)

  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'right')

  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, transform_resting.rotation, 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topleft, transform_resting.corners.topright)
  lu.assertBaseEquals(resting_base, original_base)
end

function test_transform_to_shape()
  local base = build_base("base 4Bw # 16")
  local transform = calculate_transform(base)
  local corners = transform['corners']
  local actual = transform_to_shape(transform)
  lu.assertEquals(actual[1], corners['topleft'])
  lu.assertEquals(actual[2], corners['topright'])
  lu.assertEquals(actual[3], corners['botright'])
  lu.assertEquals(actual[4], corners['botleft'])
end

function test_make_general_adds_suffix()
  -- Setup
  local old_reset_state = reset_state
  reset_state = function() end

  local base = build_base("base Archers #12")

  -- Exercise
  make_general(base)

  -- Validate
  local actual = base.getName()
  lu.assertEquals(actual, "base Archers  General #12")

  -- Cleanup
  reset_state = old_reset_state
end

function test_make_general_adds_suffix_when_number_missing()
  -- Setup
  local old_reset_state = reset_state
  reset_state = function() end
  local error_called = false
  local old_print_error = print_error
  print_error = function(message)
	  error_called = true
  end

  local base = build_base("base Archers")

  -- Exercise
  make_general(base)

  -- Validate
  local actual = base.getName()
  lu.assertEquals(actual, "base Archers  General")
  lu.assertEquals(true, error_called)

  -- Cleanup
  reset_state = old_reset_state
  print_error = old_print_error
end

function test_inches_to_mu_display_string_1_decimal_digit()
  local actual = inches_to_mu_display_string(4.87 * g_movement_unit_in_inches)
  lu.assertEquals(actual, "4.9 MU")
end

function test_mu_display_string_rounds_up()
  local actual = inches_to_mu_display_string(4.86 * g_movement_unit_in_inches)
  lu.assertEquals(actual, "4.9 MU")
end

function test_mu_display_string_rounds_down()
  local actual = inches_to_mu_display_string(4.82 * g_movement_unit_in_inches)
  lu.assertEquals(actual, "4.8 MU")
end

os.exit( lu.LuaUnit.run() )
