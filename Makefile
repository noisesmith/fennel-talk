%.lua: src/%.fnl
	fennel --compile $< > $@

%-test: test/%-test.fnl %.lua
	fennel $< all

csound.lua: csound-raw.lua macros/util.fnl

composition.lua: csound.lua

client-server.lua: ipc.lua util.lua sque.lua

audio-process.lua: csound.lua client-server.lua

test: util.lua csound-test util-test ipc-test client-server-test

clean:
	rm -f *.lua test.wav
