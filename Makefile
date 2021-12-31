.PHONY: clean run
RACKS_FLAGS = --enable-self-tail --enable-flatten-if --js-beautify

run: build
	@echo "Starting app ..."
	node --experimental-json-modules ./build/modules/server.rkt.js

build: server.rkt | node_modules
	@echo "Compiling app ..."
	racks $(RACKS_FLAGS) --build-dir build server.rkt
	cp -r public build/modules
	cp -r src build/modules

node_modules: package.json
	npm install
clean:
	rm -rf build/
