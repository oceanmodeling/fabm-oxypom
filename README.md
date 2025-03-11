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

**DO+BGC** is a family of models for Dissolved Oxygen Dynamics plus simple biogeochemistry implemented in `FABM`.

## Description
**DO+BGC** includes:

* `OxyPOM` (**Oxygen + Particulate Organic Matter**): Simulates oxygen consumption and production in river based on [Holzwarth and Wirtz, 2018](https://doi.org/10.1016/j.ecss.2018.01.020). 
* `DiaMo` (**Diagnostic Model**): Simulates oxygen consumption and production using a statistical inspired model (WIP). 

The code of these models is located in the directory `.\src\oxypom` and `.\src\diamo`, and future code developed as part of this model should be here included.

## Installation and usage
* Requires the last version of `FABM` and the last version of `GOTM`.
* The model is run with the script `gotm-installation.sh`   

## Testcases
Currently, we include a testcases using `GOTM` as physical driver in the Elbe `estuary` in 2005-2024.
To run the testcase go to the directory `.\testcases`.

* The last version of `GOTM` and `FABM` is required as well as a FORTRAN compiler and CMake.

* These variables must be defined: 
    - `GOTMDIR` base directory of GOTM source code
    - `FABMDIR` base directory of FABM source code
    - `DOBGCPDIR` base directory of dobgcp source code

In this testcase they are defined as:

```
export GOTMDIR=$HOME/tools/gotm/code
export FABMDIR=$HOME/tools/fabm/fabm
export DOBGCPDIR=$HOME/tools/dobgcp/src
```

* The model is build with the script `gotm-installation.sh`. 
This script creates the directory `.\build` with the building files, and a copy of `gotm` executable in the `.\estuary` directory.

Now move to the directory `.\estuary`.

* The script `get_data.sh` download and unzip the forcing and validation data from [kuestendaten.de](https://www.kuestendaten.de) in a newly created directory `.\data`.
The downloaded files are used under license [DL-DE->Zero-2.0](https://www.govdata.de/dl-de/zero-2-0).

* The script `setup_data.R` formatted the data to be read by `GOTM`. It generates the file `meteofile.csv`.

* Run the model with `./gotm`. It generates the files `output.nc` and `restart.nc`.

* The script `plot_output.R` analyses the model output.
If everything is correct, the figure `estuary_validation.png` should be produced.
It displays a comparison of simulation and data for temperature and dissolved oxygen values.


The total procedure is:

```
bash gotm-installation.sh
cd estuary
bash get_data.sh
Rscript setup_data.R
./gotm
RScript plot_output.R
```

New testcases for this model need to be here included.

## To do
- [ ] Create the complete script for the testcases
- [ ] surface oxygen in DiaMo is not working well.
- [ ] the fabm 0d is not compiling.
- [x] check the names of the plotted figures.
- [ ] check the right licensing for this code

## License
CC0-1.0

## Project status
This is part of the `DAM-ElbeXtreme` project.