version:
	./scripts/generate-version-nim.sh

build: version 
	nimble build

cross: version
	./scripts/cross-compile.sh