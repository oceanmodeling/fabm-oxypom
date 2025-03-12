<!--
SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
SPDX-License-Identifier: CC0-1.0
SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>
--> 

<!--
[![Open Code](https://img.shields.io/badge/_%3C%2F%3E-open_code-92c02e?logo=gnometerminal&logoColor=lightblue&link=https://www.comses.net/resources/open-code-badge/)](LINK HERE)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8430014.svg)](LINK HERE)
[![JOSS status](https://joss.theoj.org/papers/84a737c77c6d676d0aefbcef8974b138/status.svg)](LINK HERE)
-->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!--
[![OpenSSF Best Practices](https://bestpractices.coreinfrastructure.org/projects/7240/badge)](https://bestpractices.coreinfrastructure.org/projects/7240)
-->
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](./doc/contributing/code_of_conduct.md)
<!-- For this we need to open the repo
[![REUSE status](https://api.reuse.software/badge/github.com/fsfe/reuse-tool)](https://api.reuse.software/info/codebase.helmholtz.cloud/mussel/netlogo-northsea-species)
--> 
<!-- [![Prettier style](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square)](https://github.com/prettier/prettier)
[![CodeFactor](https://www.codefactor.io/repository/github/platipodium/vinos/badge)](https://www.codefactor.io/repository/github/platipodium/vinos
[![Pipeline](https://codebase.helmholtz.cloud/mussel/netlogo-northsea-species/badges/main/pipeline.svg)](https://codebase.helmholtz.cloud/mussel/netlogo-northsea-species/-/pipelines) 
-->

# DO+BGC (Dissolved Oxygen and BioGeoChemistry)

**DO+BGC** is a family of models for Dissolved Oxygen Dynamics plus simple BioGeoChemistry implemented in `FABM`.

## Description
Currently **DO+BGC** includes:

* `OxyPOM` (**Oxygen + Particulate Organic Matter**): Simulates oxygen consumption and production in river based on [Holzwarth and Wirtz, 2018](https://doi.org/10.1016/j.ecss.2018.01.020). 
* `DiaMo` (**Diagnostic Model**): Simulates oxygen consumption and production using a statistical inspired model (WIP). 

The code of these models is located in the directory `.\src` (e.g., `.\src\oxypom` and `.\src\diamo`), and future code developed as part of this model should be here included.

## Requirements

* This model requires:
    - `FABM` (v1 or above) available in [fabm github](https://github.com/fabm-model/fabm/). 
    It can be cloned using `git clone https://github.com/fabm-model/fabm.git fabm`.

The following is not required to build and run the model but it is for running the test case:

* The physical driver:
    - `GOTM` (v6.0 latest stable release) available in [gotm github](https://github.com/orgs/gotm-model/repositories).
    It can be cloned using via `git clone --recursive https://github.com/gotm-model/code.git -b v6.0 gotm6`.

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
    - `GOTM_DIR` base directory of GOTM source code
    - `FABM_DIR` base directory of FABM source code
    - `DOBGCP_DIR` base directory of dobgcp source code

By default they are:

```
export GOTM_DIR=$HOME/tools/gotm6
export FABM_DIR=$HOME/tools/fabm/fabm
export DOBGCP_DIR=$HOME/tools/dobgcp/src
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
- [x] the fabm 0d is not compiling.
- [x] check the names of the plotted figures.
- [x] check the right licensing for this code

## License
Apache-2.0

## Project status
This is part of the `DAM-ElbeXtreme` project.