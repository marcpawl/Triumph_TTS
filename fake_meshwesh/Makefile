# Generate the lua files needed for TTS


.PHONY: army_data
army_data:
	rm -rf army_data
	mkdir army_data
	python3 tts_army.py

# Generate the JSON schemas
.PHONY: schema
schema:
	python3 -m genson  --indent 2 \
	  --schema-uri https://github.com/marcpawl/Triumph_TTS.git/armyLists/summary.schema.json/v20230918 \
	   armyLists/summary.json > armyLists/summary.schema.json
	python3 -m genson  --indent 2 \
	  --schema-uri https://github.com/marcpawl/Triumph_TTS.git/armyLists/thematicCategories.schema.json.schema.json/v20230918 \
	  $(shell ls armyLists/*.thematicCategories.json | head -100) \
	  > armyLists/thematicCategories.schema.json
	python3 -m genson  --indent 2 \
	  --schema-uri https://github.com/marcpawl/Triumph_TTS.git/armyLists/allyOptions.schema.json.schema.json/v20230918 \
	  $(shell ls armyLists/*.allyOptions.json | head -100) \
	  > armyLists/allyOptions.schema.json
	python3 -m genson  --indent 2 \
	  --schema-uri https://github.com/marcpawl/Triumph_TTS.git/armyLists/allyOptions.schma.json.schema.json.schema.json/v20230918 \
	  $(shell ls armyLists/*.allyOptions.json | head -100) \
	  > armyLists/allyOptions.schma.json
	python3 -m genson  --indent 2 \
	  $(shell ls armyLists/*.army.json | head -100)\
	   > armyLists/army.schema.json


# Get a local caopy of the Meshwesh JSON
.Phony: clone
clone:
	rm -rf armyLists
	mkdir armyLists
	curl -o armyLists/summary.json 'https://meshwesh.wgcwar.com/api/v1/armyLists?summary=true'
	python3 clone.py
	${MAKE} schema

