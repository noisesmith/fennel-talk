%.lua: src/%.fnl
	fennel --compile $< > $@

%-test: test/%-test.fnl %.lua util.lua
	fennel $< all

csound.lua: csound-raw.lua macros/util.fnl

composition.lua: csound.lua

client-server.lua: ipc.lua util.lua sque.lua

audio-process.lua: csound.lua client-server.lua

test: audio-process-test client-server-test csound-test ipc-test sque-test util-test

clean:
	rm -f *.lua test.wav
