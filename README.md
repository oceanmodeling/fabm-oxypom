<!---
SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
SPDX-License-Identifier: CC0-1.0
SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>
-->

# DO+BGC (Dissolved Oxygen and BioGeoChemistry)

**DO+BGC** is a family of models for Dissolved Oxygen Dynamics plus simple BioGeoChemistry implemented in `FABM`.

## Description
Currently **DO+BGC** includes:

* `OxyPOM` (**Oxygen + Particulate Organic Matter**): Simulates oxygen consumption and production in river based on [Holzwarth and Wirtz, 2018](https://doi.org/10.1016/j.ecss.2018.01.020). 
* `DiaMo` (**Diagnostic Model**): Simulates oxygen consumption and production using a statistical inspired model (WIP). 

The code of these models is located in the directory `.\src' (e.g., `.\src\oxypom` and `.\src\diamo`), and future code developed as part of this model should be here included.

## Requirements

* This model requires:
    - `FABM` (v1 or above) available in [fabm github](https://github.com/fabm-model/fabm/)    

The following is not required to build and run the model but it is for running the test case:

* The physical driver:
    - `GOTM` (tested with v6) available in [gotm github](https://github.com/orgs/gotm-model/repositories)

* The script for downloading forcing and validation data requires the following shell commands:
    - `wget`
    - `unzip`
    - `sed`

* The scripts for generating forcing files setup and plotting routines for model validation require:
    - `R` (v4.3 or above) available in [r home](https://www.r-project.org/) with the library `ncdf4` installed.

## Testcases

We provide the model with a testcase in the directory `.\testcases`.
New testcases for **DO+BGC** should be included in a single directory within `.\testcases`.
Currently, we include the testcase estuary.

### Testcase Estuary
This setup uses the physical driver `GOTM` to simulate the water column dynamics in the Elbe estuary in 2005-2024.

To run the testcase go to the directory `.\testcases`.

* The model is build with the script `gotm-installation.sh`, in where these variables must be defined: 
    - `GOTMDIR` base directory of GOTM source code
    - `FABMDIR` base directory of FABM source code
    - `DOBGCPDIR` base directory of dobgcp source code

By default they are:

```
export GOTMDIR=$HOME/tools/gotm/code
export FABMDIR=$HOME/tools/fabm/fabm
export DOBGCPDIR=$HOME/tools/dobgcp/src
```

* The script `gotm-installation.sh` creates the directory `.\build` with the building files, and a copy of `gotm` executable in the `.\estuary` directory.

Now move to the directory `.\estuary`.

* The script `get_data.sh` download and unzip the forcing and validation data from [kuestendaten.de](https://www.kuestendaten.de) in a newly created directory `.\data`.
The downloaded files are used under license [DL-DE->Zero-2.0](https://www.govdata.de/dl-de/zero-2-0).

* The script `setup_data.R` formatted the data to be read by `GOTM`. It generates the file `meteofile.csv`.

* Run the model with `./gotm`. It generates the files `output.nc` and `restart.nc`.

* The script `plot_output.R` analyses the model output.

If everything is correct, the figure `estuary_validation.png` should be produced.

It displays a comparison of simulation and data for temperature and dissolved oxygen values.


Summarizing, the entire procedure is:

```
bash gotm-installation.sh
cd estuary
bash get_data.sh
Rscript setup_data.R
./gotm
RScript plot_output.R
```

## To do
- [ ] Create the complete script for the testcases
- [ ] surface oxygen in DiaMo is not working well.
- [ ] the fabm 0d is not compiling.
- [x] check the names of the plotted figures.
- [ ] check the right licensing for this code

## License
Apache-2.0

## Project status
This is part of the `DAM-ElbeXtreme` project.