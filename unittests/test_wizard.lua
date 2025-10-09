lu = require('externals/luaunit/luaunit')
require("Triumph_TTS/scripts/wizard")

function test_is_coast_available_for_topography()
    lu.assertTrue( is_coast_available_for_topography('arable') )
    lu.assertFalse( is_coast_available_for_topography('forest') )
    lu.assertFalse( is_coast_available_for_topography('hilly') )
    lu.assertFalse( is_coast_available_for_topography('steppe') )
    lu.assertFalse( is_coast_available_for_topography('dry') )
    lu.assertTrue( is_coast_available_for_topography('marsh') )
    lu.assertTrue( is_coast_available_for_topography('delta') )
end


os.exit( lu.LuaUnit.run() )
