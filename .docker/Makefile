# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor: Carsten Lemmen <carsten.lemmen@hereon.de>

.PHONY: default push fabm

default:
	@echo Valid Makefile targets are fabm and push

fabm:
	@docker image inspect platipodium/fabm  > /dev/null 2>&1 || \
	  docker build -f ./Dockerfile-fabm -t platipodium/fabm \
	  ..

push: fabm
	docker login -u ${CI_REGISTRY_USER} -p ${CI_WRITE_REGISTRY_TOKEN} ${CI_REGISTRY} && \
	@for V in "fabm"; do  \
	  IMAGEID=docker images -q platipodium/$$V && \
	  docker tag ${IMAGEID} ${CI_REGISTRY}/dam-elbextreme/oxypom/$$V && \
	  docker image push ${CI_REGISTRY}/dam-elbextreme/oxypom/$$V && \
	done