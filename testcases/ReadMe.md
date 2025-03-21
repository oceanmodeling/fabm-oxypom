<!---
SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
SPDX-License-Identifier: CC0-1.0
SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>
-->

# Testcases

This directory includes testcases for validation of OxyPOM, DiaMO and oxypom/light in a station in the Elbe estuary (Cuxhaven).
It includes:

* estuary: long term simulation of oxygen in a station in the Elbe estuary (Cuxhaven).
* light: comparison of oxypom/light with default light implementation.

Detailed information of how to run each testcase, configuration, and auxiliary files, are included in the subdirectories `./estuary` and `./light`.

To run each test case the scripts `run-estuary-testcase.sh` and `run-light-testcase.sh` can also be executed.

The cmake instructions for compiling OxyPOM and DiaMO with GOTM and FABM-0D box as physical drivers are included in `gotm-installation.sh` and `fabm-installation.sh`, respectively.


## Licenses

Apache-2.0
CC0-1.0

## Project status

This is part of the `DAM-ElbeXtreme` project.