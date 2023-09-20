
.PHONY: all
all: index.html

index.html: $(wildcard src/*) docker
	python3 json2elm.py 
	docker run \
          --rm \
	  -v $(abspath .):$(abspath .) -w $(abspath .) \
	  $(shell cat docker/output/iid_elm) \
	  elm make src/Main.elm

.PHONY: docker
docker:
	${MAKE} -C docker

.PHONY: clean
clean:
	${MAKE} -C docker clean
	rm -rf output
	rm -f index.html
	rm -rf elm-stuff


.DELETE_ON_ERROR:
