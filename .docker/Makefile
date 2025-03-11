# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor: Carsten Lemmen <carsten.lemmen@hereon.de>

.PHONY: default push pandoc

default:
	@echo Valid Makefile targets are pandoc and push

pandoc:
	@docker image inspect platipodium/pandoc:3.1.6.2  > /dev/null 2>&1 || \
	  docker build -f ./Dockerfile-pandoc -t platipodium/pandoc \
	  --build-arg PANDOC_VERSION=3.1.6.2 ..
	@docker image inspect platipodium/pandoc:3.1.12.2  > /dev/null 2>&1 || \#
	  docker build -f ./Dockerfile-pandoc -t platipodium/pandoc \
	  --build-arg PANDOC_VERSION=3.1.12.2 ..

push: pandoc
	docker login -u ${CI_REGISTRY_USER} -p ${CI_WRITE_REGISTRY_TOKEN} ${CI_REGISTRY} && \
	@for V in "pandoc:3.1.12.2" "pandoc:3.1.6.2"; do  \
	  IMAGEID=docker images -q platipodium/$$V && \
	  docker tag ${IMAGEID} ${CI_REGISTRY}/dam-elbextreme/dobgcp/$$V && \
	  docker image push ${CI_REGISTRY}/dam-elbextreme/dobgcp/$$V && \
	done