
all: output/army_data.json
all: output/docker_elm.iid

output/army_data.json:
	export "LUA_PATH=../../?.ttslua;../?.ttslua;?.lua;../../?.lua;../submodules/lunajson/src/?.lua" && \
	    lua army_data_json.lua > $@

output/docker_elm.iid: Dockerfile_elm
	docker build --iidfile $@ --file Dockerfile_elm .


.DELETE_ON_ERROR:
