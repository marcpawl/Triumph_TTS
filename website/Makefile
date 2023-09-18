
all: data
	${MAKE} -C 1page

.PHONY: data
data: output/army_data.json  output/armies_data.json
output/army_data.json output/armies_data.json: army_data_json.lua
	mkdir -p $(dir $@)
	export "LUA_PATH=../../?.ttslua;../?.ttslua;?.lua;../../?.lua;../submodules/lunajson/src/?.lua" && \
	    lua army_data_json.lua

.PHONY: clean
clean:
	rm -rf output
	${MAKE} -C 1page clean

.DELETE_ON_ERROR:
