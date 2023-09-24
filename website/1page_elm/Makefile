
ifneq (${IN_DOCKER},true)
DOCKER_RUN=docker run \
          --rm \
	  -v $(abspath ../..):/Triumph_TTS \
	  -w /Triumph_TTS/website/1page_elm \
	  $(shell cat docker/output/iid_elm) 
else
DOCKER_RUN=
endif


.PHONY: all
all: elm.js

elm.js: $(wildcard src/*) docker
ifneq (${IN_DOCKER},true)
	python3 json2elm.py 
endif
	${DOCKER_RUN} elm make src/Main.elm --output elm.js

.PHONY: docker
docker:
ifneq (${IN_DOCKER},true)
	    ${MAKE} -C docker
endif
	
.PHONY: check
# Run test cases
check:
	${DOCKER_RUN} elm-test

.PHONY: clean
clean:
	${MAKE} -C docker clean
	rm -rf output
	rm -f elm.js
	rm -rf elm-stuff


.DELETE_ON_ERROR:
