# Copyright (c) 2023, NVIDIA CORPORATION.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


.DEFAULT_GOAL := all

include Makefile.def

##### Global variables #####
REGISTRY ?= ghcr.io/llmos-ai
VERSION  ?= 1.0.0

##### Using `BUILD_PLATFORMS=linux/arm64 make all` to build arm64 arch image locally
##### Using `BUILD_PLATFORMS=linux/amd64,linux/arm64 make push-latest` to build and publish multi-arch image
BUILD_PLATFORMS ?= linux/amd64

##### Public rules #####

all: ubuntu20.04

build:
	docker buildx build --platform $(BUILD_PLATFORMS) \
		--tag $(REGISTRY)/volcano-vgpu-device-plugin:$(VERSION)\
		--file docker/Dockerfile.bookworm .

push:
	docker buildx build --platform $(BUILD_PLATFORMS) --push \
		--tag $(REGISTRY)/volcano-vgpu-device-plugin:$(VERSION)\
		--file docker/Dockerfile.bookworm .

BIN_DIR=_output/bin
RELEASE_DIR=_output/release
REL_OSARCH=linux/amd64

init:
	mkdir -p ${BIN_DIR}
	mkdir -p ${RELEASE_DIR}

gen_bin: init
	go get github.com/mitchellh/gox
	CGO_ENABLED=1 gox -osarch=${REL_OSARCH} -ldflags ${LD_FLAGS} -output ${BIN_DIR}/${REL_OSARCH}/volcano-vgpu-device-plugin ./cmd/vgpu
