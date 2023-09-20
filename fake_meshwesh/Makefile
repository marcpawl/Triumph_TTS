# Generate the lua files needed for TTS


.PHONY: army_data
army_data:
	rm -rf army_data
	mkdir army_data
	python3 tts_army.py

# Generate the JSON schemas
.PHONY: schema
schema:
	python3 make_schemas.py

# Get a local caopy of the Meshwesh JSON
.Phony: clone
clone:
	rm -rf armyLists
	mkdir armyLists
	curl -o armyLists/summary.json 'https://meshwesh.wgcwar.com/api/v1/armyLists?summary=true'
	python3 clone.py
	${MAKE} schema

