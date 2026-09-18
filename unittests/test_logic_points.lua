lu = require('externals/luaunit/luaunit')
require("Triumph_TTS/fake_meshwesh/army_data/all_armies")
require("Triumph_TTS/scripts/logic_dead")

function test_get_army_builder_points_for_base_defintions_uses_points_from_tool_tip()
  local def = g_base_definitions[g_str_68c995d2579163001588831e] -- a rabble
  local actual = get_army_builder_points_for_base_definitions({def})
  lu.assertEquals(actual, 2)
end

function test_get_victory_points_for_base_defintions_uses_points_from_tool_tip()
  local def = g_base_definitions[g_str_68c995d2579163001588831e] -- a rabble
  local actual = get_victory_points_for_base_definitions({def})
  lu.assertEquals(actual, 2)
end

function test_get_army_builder_points_for_base_defintion_uses_max_for_dismounting()
  local def = g_base_definitions[g_str_68c995dd5791630015889fca_general_mounted]
  local actual = get_army_builder_points_for_base_definition(def)
  lu.assertEquals(actual, 4)
end


function test_get_army_builder_points_for_base_defintion_adds_1_point_for_any_deployment_dismounting()
  local def1 = g_base_definitions[g_str_68c995dd5791630015889fca_general_mounted]
  local def2 = g_base_definitions[g_str_68c995dd5791630015889fca_mounted]
  local actual = get_army_builder_points_for_base_definitions({def1, def2})
  lu.assertEquals(actual, 9)
end

function test_get_army_builder_points_for_base_defintion_adds_2_points_for_any_mid_battle_dismounting()
  local def1 = g_base_definitions[g_str_68c995de579163001588a208_general_mounted]
  local def2 = g_base_definitions[g_str_68c995de579163001588a208_general_mounted]
  local actual = get_army_builder_points_for_base_definitions({def1, def2})
  lu.assertEquals(actual, 10)
end

function test_get_victory_points_for_base_defintion_uses_higher_score_mid_battle_dismounting_mounted()
  -- setup
  local def1 = { dismount_as="def2", mid_battle_dismounting=true, troop_type="Bad Horse"}
  local def2 = { dismounted_from="def2", troop_type = "Elite Foot"}
  g_base_definitions["def1"] = def1
  g_base_definitions["def2"] = def2

  -- exercise
  local actual = get_victory_points_for_base_definitions({def1})
  -- validate
  lu.assertEquals(actual, 4)

  -- cleanup
  g_base_definitions["def1"] = nil
  g_base_definitions["def2"] = nil
end

function test_get_victory_points_for_base_defintion_uses_higher_score_mid_battle_dismounting_dismounted()
  -- setup
  local def1 = { dismount_as="def2", mid_battle_dismounting=true, troop_type="Knights"}
  local def2 = { dismounted_from="def2", dismounted_from="def1", troop_type = "Horde"}
  g_base_definitions["def1"] = def1
  g_base_definitions["def2"] = def2

  -- exercise
  local actual = get_victory_points_for_base_definitions({def2})
  -- validate
  lu.assertEquals(actual, 4)

  -- cleanup
  g_base_definitions["def1"] = nil
  g_base_definitions["def2"] = nil
end


function test_get_army_builder_points_for_charging_camelry_1_point_less_than_normal()
  local def = g_base_definitions[g_str_68c995df579163001588a487_charging_camelry]
  local actual = get_army_builder_points_for_base_definition(def)
  -- knights normally cost 4 points
  lu.assertEquals(actual, 3)
end

function test_get_victory_points_for_charging_camelry_3()
  local def = g_base_definitions[g_str_68c995df579163001588a487_charging_camelry]
  local actual = get_victory_points_for_base_definition(def)
  -- knights normally cost 4 points
  lu.assertEquals(actual, 3)
end

function test_get_army_builder_points_for_armored_camelry_1_point_less_than_normal()
  local def = g_base_definitions[g_str_68c995d95791630015889572_armored_camelry]
  local actual = get_army_builder_points_for_base_definition(def)
  -- Cataphracts normally cost 4 points
  lu.assertEquals(actual, 3)
end

function test_get_victory_points_for_armored_camelry_3()
  local def = g_base_definitions[g_str_68c995d95791630015889572_armored_camelry]
  local actual = get_victory_points_for_base_definition(def)
  -- Cataphracts normally cost 3 points
  lu.assertEquals(actual, 3)
end

function test_get_army_builder_points_for_1_mobile_infantry()
  local def = g_base_definitions[g_str_68c995d457916300158888cd_mounted_mobile_infantry]
  local actual = get_army_builder_points_for_base_definitions({def})
  -- same costs as normal
  lu.assertEquals(actual, 2)
end

function test_get_army_builder_points_for_3_mobile_infantry()
  local def = g_base_definitions[g_str_68c995d457916300158888cd_mounted_mobile_infantry]
  local actual = get_army_builder_points_for_base_definitions({def,def,def})
  -- 1 extra for more than 1 mobile infranty
  lu.assertEquals(actual, 7)
end

function test_get_army_builder_points_for_2_mobile_infantry()
  local def = g_base_definitions[g_str_68c995d457916300158888cd_mounted_mobile_infantry]
  local actual = get_army_builder_points_for_base_definitions({def,def})
  -- 1 extra for more than 1 mobile infranty
  lu.assertEquals(actual, 5)
end

function test_get_victory_points_for_mobile_infantry_mounted()
  local def = g_base_definitions[g_str_68c995d457916300158888cd_mounted_mobile_infantry]
  local actual = get_victory_points_for_base_definitions({def})
  -- Bow levy
  lu.assertEquals(actual, 2)
end

function test_get_victory_points_for_mobile_infantry_dismounted()
  local def = g_base_definitions[g_str_68c995d457916300158888cd_dismounted_mobile_infantry]
  local actual = get_victory_points_for_base_definitions({def})
  -- Bow levy
  lu.assertEquals(actual, 2)
end

function test_get_army_builder_points_plaustrella_one_point_per_stand()
  local def= g_base_definitions[g_str_68c995e1579163001588aac5_plaustrella]
  local actual = get_army_builder_points_for_base_definitions({def})
  -- heavy foot are normally 3
  lu.assertEquals(actual, 4)
end

function test_get_victory_points_plaustrella_one_point_per_stand()
  local def= g_base_definitions[g_str_68c995e1579163001588aac5_plaustrella]
  local actual = get_victory_points_for_base_definitions({def})
  -- heavy foot are normally 3
  lu.assertEquals(actual, 4)
end

function test_base_definition_indicates_shower_shooting()
  local def= g_base_definitions[g_str_68c995e6579163001588b9b8_shower_shooting]
  lu.assertTrue(def.shower_shooting)
end

function test_get_army_builder_points_shower_shooting_one_point_per_stand()
  local def= g_base_definitions[g_str_68c995e6579163001588b9b8_shower_shooting]
  local actual = get_army_builder_points_for_base_definitions({def})
  -- Elite cavalry are normally 4
  lu.assertEquals(actual, 5)
end

function test_get_victory_points_shower_shooting_one_point_per_stand()
  local def= g_base_definitions[g_str_68c995e6579163001588b9b8_shower_shooting]
  local actual = get_victory_points_for_base_definitions({def})
  -- Elite cavalry are normally 4
  lu.assertEquals(actual, 5)
end

function test_get_army_builder_points_camp()
  local def= g_base_definitions[g_str_5fb1b9eae1af060017709e10_camp]
  local actual = get_army_builder_points_for_base_definitions({def})
  lu.assertEquals(actual, 0)
end

function test_get_victory_points_camp()
  local def= g_base_definitions[g_str_5fb1b9eae1af060017709e10_camp]
  local actual = get_victory_points_for_base_definitions({def})
  lu.assertEquals(actual, 8)
end

function test_get_army_builder_points_fortified_camp()
  local def= g_base_definitions[g_str_5fb1b9eae1af060017709e10_camp_fortified]
  local actual = get_army_builder_points_for_base_definitions({def})
  -- camps are normally 0
  lu.assertEquals(actual, 1)
end

function test_get_victory_points_fortified_camp()
  local def= g_base_definitions[g_str_5fb1b9eae1af060017709e10_camp_fortified]
  local actual = get_victory_points_for_base_definitions({def})
  -- no extra VP for forified camp
  lu.assertEquals(actual, 8)
end

function test_get_army_builder_points_pack_train()
  local def= g_base_definitions[g_str_5fb1b9d9e1af0600177093ad_camp_pack_train]
  local actual = get_army_builder_points_for_base_definitions({def})
  -- camps are normally 0
  lu.assertEquals(actual, 1)
end

function test_get_victory_points_pack_train()
  local def= g_base_definitions[g_str_5fb1b9d9e1af0600177093ad_camp]
  local actual = get_victory_points_for_base_definitions({def})
  lu.assertEquals(actual, 8)
end

function test_get_army_builder_points_standard_wagon()
  local def= g_base_definitions[g_str_5fb1b9ede1af060017709fb6_camp_standard_wagon]
  local actual = get_army_builder_points_for_base_definitions({def})
  -- camps are normally 0, and standard wagons have no extra cost.
  lu.assertEquals(actual, 0)
end

function test_get_victory_points_standard_wagon()
  local def= g_base_definitions[g_str_5fb1b9ede1af060017709fb6_camp_standard_wagon]
  local actual = get_victory_points_for_base_definitions({def})
  lu.assertEquals(actual, 8)
end

function test_get_army_builder_points_elephant_screen()
  local def= g_base_definitions[g_str_68c995d95791630015889464_elephant_screen]
  local actual = get_army_builder_points_for_base_definitions({def,def,def})
  -- An extra two points for the elephant screen
  lu.assertEquals(actual, 14)
end

function test_get_victory_points_elephant_screen()
  local def= g_base_definitions[g_str_68c995d95791630015889464_elephant_screen]
  local actual = get_victory_points_for_base_definitions({def})
  -- No points for the elephant screen
  lu.assertEquals(actual, 4)
end

os.exit( lu.LuaUnit.run() )
