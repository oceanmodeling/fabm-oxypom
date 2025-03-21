<!---
SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
SPDX-License-Identifier: CC0-1.0
SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>
-->

# Testcase Estuary `./testcases/estuary`

This directory includes a testcase for validation of OxyPOM and DiaMO in a station in the Elbe estuary (Cuxhaven).
It includes:

* configuration files
* external data acquisition and management

If successful, the figure `estuary_validation.png` should be produced.

Typically, no editing is needed to any file.
The model to test can be changed by modifying the `use:` variable to each model instance in `fabm.yaml`.

## Configuration files

Three configuration files are required to set-up the simulation:

* `gotm.yaml`: physical configuration (coordinates, tidal components, depth, etc.) and location of forcing files.

* `fabm.yaml`: configuration (parameterization and initial conditions) for OxyPOM and DiaMO models.

* `output.yaml`: configuration for model output.

## External data acquisition and management

Three scripts are required to set-up the simulation.
To download and prepare the data for modelling the scripts are:

* `get_data.sh`: download and unzip the forcing and validation data from [kuestendaten.de](https://www.kuestendaten.de) in a newly created directory `.\data`.
The downloaded files are used under license [DL-DE->Zero-2.0](https://www.govdata.de/dl-de/zero-2-0).

* `setup_data.R`: format the data to be read by `GOTM`. It generates the file `.\data\meteofile.csv`.

Finally, to plot a validation figure the script is:

* `plot_output.R` analyses the model output.  
It displays a comparison of simulation and data for temperature and dissolved oxygen values.

## Licenses

Apache-2.0
CC0-1.0

## Project status

This is part of the `DAM-ElbeXtreme` project.