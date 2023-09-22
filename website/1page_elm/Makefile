
.PHONY: all
all: elm.js

elm.js: $(wildcard src/*) docker
	python3 json2elm.py 
	docker run \
          --rm \
	  -v $(abspath .):$(abspath .) -w $(abspath .) \
	  $(shell cat docker/output/iid_elm) \
	  elm make src/Main.elm --output elm.js

.PHONY: docker
docker:
	${MAKE} -C docker

.PHONY: clean
clean:
	${MAKE} -C docker clean
	rm -rf output
	rm -f elm.js
	rm -rf elm-stuff


.DELETE_ON_ERROR:
