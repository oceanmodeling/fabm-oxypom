!! SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
!! SPDX-License-Identifier: CC0-1.0
!! SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

# ./testcases/estuary

This directory includes a testcase for validation of **DO+BGC** in a station in the Elbe estuary (Cuxhaven).
It includes:
* configuration files
* external data acquisition and management

## Configuration files

Three configuration files are required to set-up the simulation:

* `gotm.yaml`: physical configuration (coordinate) forcing files origin.

* `fabm.yaml`: configuration for **DO+BGC** models

* `output.yaml`: configuration for model output

## External data acquisition and management

Three scripts are required to set-up the simulation, two of them download and prepare the data for modelling, and the third plot a validation figure. 

* `get_data.sh`: download and unzip the forcing and validation data from [kuestendaten.de](https://www.kuestendaten.de) in a newly created directory `.\data`.
The downloaded files are used under license [DL-DE->Zero-2.0](https://www.govdata.de/dl-de/zero-2-0).

* `setup_data.R`: format the data to be read by `GOTM`. It generates the file `.\data\meteofile.csv`.

* `plot_output.R` analyses the model output. 
If everything is correct, the figure `estuary_validation.png` should be produced.
It displays a comparison of simulation and data for temperature and dissolved oxygen values.

## License
CC0-1.0

## Project status
This is part of the `DAM-ElbeXtreme` project.