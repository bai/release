#!/usr/bin/env bash

# Copyright 2020 The Kubernetes Authors.
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

set -o errexit
set -o nounset
set -o pipefail

export DOCKER_CLI_EXPERIMENTAL=enabled

# Expected builder output
#
# Name:   k-release-multiarch
# Driver: docker-container
#
# Nodes:
# Name:      k-release-multiarch0
# Endpoint:  unix:///var/run/docker.sock
# Status:    running
# Platforms: linux/amd64, linux/arm64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
current_builder="$(docker buildx inspect)"

# We can skip setup if the current builder already has multi-arch
# AND if it isn't the "docker" driver, which doesn't work
if ! grep -q "^Driver: docker$"  <<<"${current_builder}" \
  && grep -q "linux/amd64" <<<"${current_builder}" \
  && grep -q "linux/arm" <<<"${current_builder}" \
  && grep -q "linux/arm64" <<<"${current_builder}" \
  && grep -q "linux/ppc64le" <<<"${current_builder}" \
  && grep -q "linux/s390x" <<<"${current_builder}"; then
  exit 0
fi

# Ensure qemu is in binfmt_misc
# NOTE: Please always pin this to a digest for predictability/auditability
# Last updated: 08/21/2020
if [ "$(uname)" == 'Linux' ]; then
  docker run --rm --privileged multiarch/qemu-user-static@sha256:c772ee1965aa0be9915ee1b018a0dd92ea361b4fa1bcab5bbc033517749b2af4 --reset -p yes
fi

# Ensure we use a builder that can leverage it (the default on linux will not)
docker buildx rm k-release-multiarch || true
docker buildx create --use --name=k-release-multiarch
docker buildx inspect --bootstrap