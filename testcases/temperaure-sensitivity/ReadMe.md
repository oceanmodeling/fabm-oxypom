<!---
SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
SPDX-License-Identifier: CC0-1.0
SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>
-->

# Testcase for OxyPOM 
This directory includes a testcase for uniform vs. nuanced temperature sensitivity in an idealized case.
It includes:

* configuration files
* data for running the model
* scripts for analyzing the data

Just run `bash test_gotm.sh`, if successful, `output_uniform.nc` and `output_sensitive.nc` should be produced.

Typically, no editing is needed to any file as long as the environment variables `GOTMDIR`, `FABMDIR`, and `OXYPOMDIR` are correctly defined in.
Otherwise edit `test_gotm.sh` to the right directories.

## Configuration files

Three configuration files are required to set-up the simulation:

* `gotm.yaml`: physical configuration (coordinates, tidal components, depth, etc.) and location of forcing files.

* `fabm.yaml`: configuration (parameterization and initial conditions) of OxyPOM models.

* `output.yaml`: configuration for model output.

## Visualization scripts

The model results can be inspected in the figures:

* `comparison.pdf`: depth-time diagrams and relative error plots of state variables and oxygen-related processes.

* `flux.pdf`: oxygen flux related to re-aeration, photosynthesis, mineralization, respiration, and nitrification in absolute and relative terms.

## External data acquisition and management

Idealized forcing data (`.\data\meteofile.csv`) inspired in the Cuxhaven sampling station in the Elbe estuary is included.

## Licenses

Apache-2.0
CC0-1.0

## To do
