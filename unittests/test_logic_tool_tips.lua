lu = require('externals/luaunit/luaunit')
require("Triumph_TTS/scripts/logic_tool_tips")
require("Triumph_TTS/scripts/utilities_lua")
require("Triumph_TTS/fake_meshwesh/army_data/all_armies")

-- Stub out print messges
print_error=function(message) end

function test_build_tool_tip_returns_empty_string_for_nil_definition()
    local actual = get_tool_tip_for_base_definition(nil)
    lu.assertEquals(actual, "")
end

function test_build_tool_tip_does_not_include_movement_for_camp()
    local def = g_base_definitions[g_str_5fb1b9f6e1af06001770a4c7_camp]
    local tip = get_tool_tip_for_base_definition(def)
    local actual = str_has_substr(tip, "MU")
    lu.assertFalse(actual)
end

function test_build_tool_tip_includes_movement()
    local def = g_base_definitions[g_str_68c995d957916300158896c0]
    local tip = get_tool_tip_for_base_definition(def)
    local actual = str_has_substr(tip, "3 MU")
    lu.assertTrue(actual)
end

function test_build_tool_tip_non_shooters()
    local def = g_base_definitions[g_str_68c995d957916300158896c3]
    local tip = get_tool_tip_for_base_definition(def)
    local actual = str_has_substr(tip, "ranged combat: /")
    lu.assertTrue(actual)
end

function test_build_tool_tip_shooters()
    local def = g_base_definitions[g_str_68c995d957916300158896c0]
    local tip = get_tool_tip_for_base_definition(def)
    local actual = str_has_substr(tip, "ranged combat: 3/")
    lu.assertTrue(actual)
end

function test_build_tool_tip_target()
    local def = g_base_definitions[g_str_68c995d957916300158896bf]
    local tip = get_tool_tip_for_base_definition(def)
    local actual = str_has_substr(tip, "ranged combat: /3")
    lu.assertTrue(actual)
end

function test_build_tool_tip_close_combat()
    local def = g_base_definitions[g_str_68c995d957916300158896bf]
    local tip = get_tool_tip_for_base_definition(def)
    local actual = str_has_substr(tip, "close combat: 2/3")
    lu.assertTrue(actual)
end

function test_build_tool_tip_target_combat_factor_missing()
    local def = g_base_definitions[g_str_5fb1b9f6e1af06001770a4c7_camp]
    local tip = get_tool_tip_for_base_definition(def)
    local actual = str_has_substr(tip, "ranged combat: /X")
    lu.assertTrue(actual)
end

function test_build_tool_tip_close_combat_camp()
    local def = g_base_definitions[g_str_5fb1b9f6e1af06001770a45e_camp]
    local tip = get_tool_tip_for_base_definition(def)
    local actual = str_has_substr(tip, "close combat: 2/2")
    print("tip is ", tip)
    lu.assertTrue(actual)
end

function test_build_tool_tip_close_combat_fortified_camp()
    local def = g_base_definitions[g_str_5fb1b9f6e1af06001770a45e_camp_fortified]
    local tip = get_tool_tip_for_base_definition(def)
    local actual = str_has_substr(tip, "close combat: 4/4")
    print("tip is ", tip)
    lu.assertTrue(actual)
end


function test_general_gets_combat_factor()
    -- setup
    local old_decorations = g_decorations
    g_decorations = {}

    local base = {
        getName = function() return "mounted" end,
        getGUID = function() return "ABCDE" end,
        base_definition_name = g_str_68c995d55791630015888add_general
    }
    g_decorations[ base.getGUID() ] = {base_definition_name =  base.base_definition_name}

    -- Exercise
    local tip = get_tool_tip_for_base(base)

    -- Verify
    local expected = "close combat:"
    local actual = str_has_substr(tip, expected)
    if not actual then
        print("expected: ", expected)
        print("tip: ", tip)
    end
    lu.assertTrue(actual)

    -- Cleanup
    g_decorations = old_decorations
end


function test_build_tool_tip_battle_card_added()
    -- setup
    local old_decorations = g_decorations
    g_decorations = {}

    local base = {
        getName = function() return "mounted" end,
        getGUID = function() return "ABCDE" end,
        base_definition_name = g_str_68c995d55791630015888add_mounted
    }
    g_decorations[ base.getGUID() ] = {base_definition_name =  base.base_definition_name}

    -- Exercise
    local tip = get_tool_tip_for_base(base)

    -- Verify
    local expected = "Deployment dismounting"
    local actual = str_has_substr(tip, expected)
    if not actual then
        print("expected: ", expected)
        print("tip: ", tip)
    end
    lu.assertTrue(actual)

    -- Cleanup
    g_decorations = old_decorations
end

function test_get_tool_tip_returns_nil_if_tool_tips_not_enabled()
    -- setup
    local orig = g_tool_tips_enabled
    g_tool_tips_enabled = false

    -- exercise
    local def = g_base_definitions[g_str_68c995d957916300158896bf]
    local tip = get_tool_tip_for_base_definition(def)

    -- validate
    lu.assertEquals(actual, nil)

    -- cleanup
    g_tool_tips_enabled = orig
end

function test_get_tool_tip_returns_tool_tip_if_tool_tips_enabled()
    -- setup
    local orig = g_tool_tips_enabled
    g_tool_tips_enabled = true

    -- exercise
    local def = g_base_definitions[g_str_68c995d957916300158896bf]
    local tip = get_tool_tip_for_base_definition(def)

    -- validate
    local actual = str_has_substr(tip, "MU")
    lu.assertTrue(actual)

    -- cleanup
    g_tool_tips_enabled = orig
end

-- Proxy bases have no base definition
function test_get_tool_tip_returns_empty_string_nil_base_definition()
    -- setup
    local orig = g_tool_tips_enabled
    g_tool_tips_enabled = true

    -- exercise
    local actual = get_tool_tip_for_base_definition(nil)

    -- validate
    lu.assertEquals(actual, "")

    -- cleanup
    g_tool_tips_enabled = orig
end

function test_get_base_type_from_name_removes_base_and_serial_number()
    local actual = get_base_type_from_name("base Archers # 3")
    lu.assertEquals(actual, "Archers")
end

function test_get_base_type_from_name_removes_general()
    local actual = get_base_type_from_name("base Archers  General # 3")
    lu.assertEquals(actual, "Archers")
end

-- asterix is added to the name of a base to indicate that there
-- is something special about it, and the tool tips should
-- be consulted
function test_get_base_type_from_name_removes_asterix()
    local actual = get_base_type_from_name("base Archers  General* # 3")
    lu.assertEquals(actual, "Archers")
end

function test_build_tool_tip_string_ranged_combat_target()
    local actual = build_tool_tip_string_ranged_combat_target(g_base_definitions['warriors'])
    lu.assertEquals(actual, "3")
end

function test_build_tool_tip_string_ranged_combat_target_mi()
    local actual = build_tool_tip_string_ranged_combat_target(g_base_definitions['warriors_mi'])
    lu.assertEquals(actual, "3-1")
end

function test_build_tool_tip_string_ranged_combat_target_general()
    local actual = build_tool_tip_string_ranged_combat_target(g_base_definitions['warriors_general'])
    lu.assertEquals(actual, "3*-1")
    
end

function test_build_tool_tip_string_ranged_combat_target_mi_general()
    local actual = build_tool_tip_string_ranged_combat_target(g_base_definitions['warriors_general_mi'])
    lu.assertEquals(actual, "3-1*-1")
end

function test_build_tool_tip_string_close_combat_vs_foot()
    local actual = build_tool_tip_string_close_combat_vs_foot(g_base_definitions['archers'])
    lu.assertEquals(actual, "2")
end

function test_build_tool_tip_string_close_combat_vs_foot_mi()
    local actual = build_tool_tip_string_close_combat_vs_foot(g_base_definitions['archers_mi'])
    lu.assertEquals(actual, "2-1")
end

function test_build_tool_tip_string_close_combat_vs_foot_general()
    local actual = build_tool_tip_string_close_combat_vs_foot(g_base_definitions['archers_general'])
    lu.assertEquals(actual, "2+1")
    
end

function test_build_tool_tip_string_close_combat_vs_foot_mi_general()
    local actual = build_tool_tip_string_close_combat_vs_foot(g_base_definitions['archers_general_mi'])
    lu.assertEquals(actual, "2-1+1")
end

function test_build_tool_tip_string_close_combat_vs_mounted()
    local actual = build_tool_tip_string_close_combat_vs_mounted(g_base_definitions['archers'])
    lu.assertEquals(actual, "4")
end

function test_build_tool_tip_string_close_combat_vs_mounted_mi()
    local actual = build_tool_tip_string_close_combat_vs_mounted(g_base_definitions['archers_mi'])
    lu.assertEquals(actual, "4-1")
end

function test_build_tool_tip_string_close_combat_vs_mounted_general()
    local actual = build_tool_tip_string_close_combat_vs_mounted(g_base_definitions['archers_general'])
    lu.assertEquals(actual, "4+1")
    
end

function test_build_tool_tip_string_close_combat_vs_mounted_mi_general()
    local actual = build_tool_tip_string_close_combat_vs_mounted(g_base_definitions['archers_general_mi'])
    lu.assertEquals(actual, "4-1+1")
end


os.exit( lu.LuaUnit.run() )
