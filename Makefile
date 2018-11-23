%.lua: src/%.fennel
	fennel --compile $< > $@

%-test: test/%-test.fennel %.lua
	fennel $< all

test: csound-test ipc-test

clean:
	rm -f *.lua test.wav
