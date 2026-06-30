# SPDX-FileCopyrightText: 2023-2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor: Carsten Lemmen <carsten.lemmen@hereon.de>

VERSION=2.0.2
DATE=$(shell  date +%Y-%m-%d)
IP=$(shell ifconfig en0 | grep inet\  | cut -d " " -f2)
PWD=$(shell pwd)

.PHONY: default clean license docker-run docker-build check \
		install-gotm install-fabm check-estuary check-light version

default:
	@echo Valid Makefile targets are: '"version"'
	@echo To build this package, follow the instructions in the Readme.md file.

LICENSE.md: python/reuse2txt.py
	reuse spdx | python python/reuse2txt.py > ./LICENSE.md

license: LICENSE.md

check: install-gotm install-fabm check-estuary check-light 

install-gotm:
	@echo "Installing GOTM..."
	@(cd testcases; bash gotm-installation.sh)

install-fabm:
	@echo "Installing FABM 0d..."
	@(cd testcases; bash fabm-installation.sh)

check-estuary:
	@echo "Checking estuary model setup..."
	@(cd testcases; bash ./run-estuary-testcase.sh)

check-light:
	@echo "Checking light model setup..."
	@(cd testcases; bash ./run-light-testcase.sh)

# This target updates all files that control the versioning
# of the software package
version:
	sed -i 's/^version: .*/version: "'$(VERSION)'"/g' CITATION.cff
	sed -i 's/^date-released: .*/date-released: "'$(DATE)'"/g' CITATION.cff
	sed -i 's/^  "version":.*/  "version": "'$(VERSION)'",'/g codemeta.json
	sed -i 's/^  "dateModified":.*/  "dateModified": "'$(DATE)'",'/g codemeta.json
