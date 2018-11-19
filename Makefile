%.lua: src/%.fennel
	fennel --compile $^ > $@

clean:
	rm *.lua
