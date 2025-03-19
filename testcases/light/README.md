<!---
SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
SPDX-License-Identifier: CC0-1.0
SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>
-->

# Testcase Estuary `./testcases/light`

This directory includes a testcase for validation of **DO+BGC** in a station in the Elbe estuary (Cuxhaven).
It includes:

* configuration files
* external data acquisition and management

Typically, no editing is needed to any file.

## Configuration files

Three configuration files are required to set-up the simulation:

* `gotm.yaml`: physical configuration (coordinate) forcing files origin.

* `fabm.new.yaml` and `fabm.ref.yaml`: configuration for **DO+BGC** models.

* `output.yaml`: configuration for model output.

## External data acquisition and management

* `model_comparison.R` analyses the model output.

If everything is correct, the figure `light_validation.png` should be produced.
It displays a comparison of the default implementation of light with the one provided in **DO+BGC**.

## Licenses

Apache-2.0
CC0-1.0

## Project status

This is part of the `DAM-ElbeXtreme` project.