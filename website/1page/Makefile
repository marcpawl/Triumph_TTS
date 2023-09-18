output/index.html: ../output/armies_data.json
output/index.html: 1page.py
	mkdir -p $(dir $@)
	PYTHONPATH=../../fake_meshwesh ./1page.py

.PHONY: clean
clean:
	rm -rf output
