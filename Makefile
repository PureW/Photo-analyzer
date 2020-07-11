# Makefile styleguide at http://clarkgrubb.com/makefile-style-guide
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

RUST_VERSION := $(shell cat .rust-version)
RUSTFLAGS ?=-g
CARGO_LOCKED=--locked
CARGO:=RUSTFLAGS="$(RUSTFLAGS) --deny warnings" cargo +$(RUST_VERSION) $(CARGO_LOCKED)


URL_DATA_PRETRAINED:=https://github.com/LaurentMazare/ocaml-torch/releases/download/v0.1-unstable/

DATA_PRETRAINED:=\
									data/resnet34.ot\
									data/resnet18.ot \
									data/vgg16.ot \
									data/vgg19.ot \
									data/inception-v3.ot
									#data/squeezenet1_0.ot \
									#data/squeezenet1_1.ot \
									#data/mobilenet-v2.ot \
									#data/efficientnet-b0.ot \
									#data/efficientnet-b1.ot \
									#data/efficientnet-b2.ot \
									#data/efficientnet-b3.ot \
									#data/efficientnet-b4.ot

.PHONY: all
all: data
	@echo "Building $@"
	$(CARGO) build --release

.PHONY: fmt
fmt:
	@echo "Executing $@"
	${CARGO} fmt --all

.PHONY: test
test: data
	@echo "Building $@"
	make test-rust
	make test-fmt
	make test-clippy

.PHONY: test-rust
test-rust:
	@echo "Building $@"
	$(CARGO) check --workspace
	$(CARGO) test --workspace

.PHONY: test-fmt
test-fmt:
	@echo "Building $@"
	$(CARGO) fmt --all -- --check

# Put clippy artifacts in separate CARGO_TARGET_DIR to speed up compilation
CLIPPY_ARTIFACTS := $(HOME)/.cargo/clippy-build-artifacts
.PHONY: test-clippy
test-clippy:
	@echo "Building $@"
	CARGO_TARGET_DIR=$(CLIPPY_ARTIFACTS) $(CARGO) clippy --all-features --all-targets

.PHONY: watch
watch:
	$(CARGO) watch -x check -x test --ignore 'data' --ignore Makefile

data: $(DATA_PRETRAINED)

data/%.ot:
	mkdir -p $(shell dirname $@)
	curl --output $@ --location $(URL_DATA_PRETRAINED)/$(shell basename $@)

.PHONY: clean
clean:
	@echo "Building $@"
	#rm -rf $(DATA_PRETRAINED)
	$(CARGO) clean

.PHONY: rust-update
rust-update:
	@echo "Executing $@"
	rustup toolchain install $(RUST_VERSION)
	rustup component add --toolchain $(RUST_VERSION) rustfmt-preview
	rustup component add --toolchain $(RUST_VERSION) clippy
