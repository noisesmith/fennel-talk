%.lua: src/%.fnl
	fennel --compile $< > $@

%-test: test/%-test.fnl %.lua
	fennel $< all

csound.lua: src/csound.fnl csound-raw.lua macros/util.fnl

test: csound-test util-test

clean:
	rm -f *.lua test.wav
