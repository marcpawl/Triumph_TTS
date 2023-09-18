
.PHONY: all
all: index.html

index.html: $(wildcard src/*) docker_iid
	docker run \
	  -v $(abspath .):$(abspath .) -w $(abspath .) \
	  $(shell cat docker/output/iid_elm) \
	  elm make src/Main.elm

.PHONY: docker_iid
docker_iid:
	${MAKE} -C docker

.PHONY: clean
clean:
	rm -rf output
	rm -f index.html
	rm -rf elm-stuff


.DELETE_ON_ERROR:
