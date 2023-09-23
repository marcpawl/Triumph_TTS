
ifneq (${IN_DOCKER},true)
output/iid_elm:
	mkdir -p $(dir $@)
	docker build --iidfile $@ .
endif

clean:
	rm -rf output
