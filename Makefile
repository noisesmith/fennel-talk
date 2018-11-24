%.lua: src/%.fnl
	fennel --compile $< > $@

%-test: test/%-test.fnl %.lua
	fennel $< all

csound.lua: src/csound.fnl csound_raw.lua macros/util.fnl

test: csound-test ipc-test

clean:
	rm -f *.lua test.wav
