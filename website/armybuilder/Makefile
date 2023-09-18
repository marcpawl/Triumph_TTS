
.PHONY: all
all: index.html

index.html: $(wildcard src/*) docker_iid
	docker -v $(pwd):$(pwd) -w $(pwd) elm make src/Hello2.elm 

.PHONY: docker_iid
docker_iid:
	${MAKE} -C docker

.PHONY: clean
clean:
	rm -rf output
	rm -f index.html
	rm -rf elm-stuff


.DELETE_ON_ERROR:
