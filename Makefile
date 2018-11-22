%.lua: src/%.fennel
	fennel --compile $^ > $@

test: ipc-test

ipc-test: ipc.lua test/ipc-test.fennel
	fennel test/ipc-test.fennel all

clean:
	rm *.lua
