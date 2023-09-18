JSON = require("lunajson")
require("Triumph_TTS/fake_meshwesh/army_data/all_armies")
require("Triumph_TTS/scripts/logic")
require("Triumph_TTS/scripts/logic_spawn_army")
require("Triumph_TTS/scripts/log")
require("Triumph_TTS/scripts/utilities")

army_data_fd = io.open("output/army_data.json", "w")
army_data_fd:write(JSON.encode(army))
army_data_fd:close()

armies_data_fd = io.open("output/armies_data.json", "w")
armies_data_fd:write(JSON.encode(armies))
armies_data_fd:close()

