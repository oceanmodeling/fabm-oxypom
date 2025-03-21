# SPDX-FileCopyrightText: 2023-2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor: Carsten Lemmen <carsten.lemmen@hereon.de>

VERSION=0.9.2
DATE=$(shell  date +%Y-%m-%d)
IP=$(shell ifconfig en0 | grep inet\  | cut -d " " -f2)
PWD=$(shell pwd)

.PHONY: default clean license docker-run docker-build

default:
	@echo Valid Makefile targets are: '"version"'
	@echo To build this package, follow the instructions in the Readme.md file.

# This target updates all files that control the versioning
# of the software package
version:
	sed -i 's/^version: .*/version: "'$(VERSION)'"/g' CITATION.cff
	sed -i 's/^date-released: .*/date-released: "'$(DATE)'"/g' CITATION.cff
	sed -i 's/^  "version":.*/  "version": "'$(VERSION)'",'/g codemeta.json
	sed -i 's/^  "dateModified":.*/  "dateModified": "'$(DATE)'",'/g codemeta.json
