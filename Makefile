%.lua: src/%.fennel
	fennel --compile $< > $@

%-test: test/%-test.fennel %.lua
	fennel $< all

csound.lua: ipc.lua

test: csound-test ipc-test

clean:
	rm -f *.lua
