.PHONY: build clean test-compile help

BINARY_NAME=facet
BINARY_PATH=src/$(BINARY_NAME)

help:
	@echo "Facet Build Commands"
	@echo "===================="
	@echo ""
	@echo "  make build          Compile the facet binary"
	@echo "  make test-compile   Compile test/ templates to dist/"
	@echo "  make clean          Remove build artifacts and dist/"
	@echo "  make help           Show this help message"

build:
	@echo "Building $(BINARY_NAME) binary..."
	crystal build src/$(BINARY_NAME).cr -o bin/$(BINARY_NAME)
	@echo "✓ Binary built: bin/$(BINARY_NAME)"

build-release:
	@echo "Building $(BINARY_NAME) release binary..."
	crystal build src/$(BINARY_NAME).cr -o bin/$(BINARY_NAME) --release
	@echo "✓ Release binary built: bin/$(BINARY_NAME)"

test-compile: build
	@echo ""
	@echo "Compiling test templates..."
	./bin/$(BINARY_NAME) compile test/

clean:
	rm -f bin/$(BINARY_NAME)
	rm -rf dist/
	@echo "✓ Cleaned"
