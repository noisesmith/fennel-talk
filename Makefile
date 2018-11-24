%.lua: src/%.fnl
	fennel --compile $< > $@

%-test: test/%-test.fnl %.lua
	fennel $< all

test: csound-test ipc-test

clean:
	rm -f *.lua test.wav
