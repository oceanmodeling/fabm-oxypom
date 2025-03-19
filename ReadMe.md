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
-->
[![Pipeline](https://codebase.helmholtz.cloud/dam-elbextreme/oxypom/badges/main/pipeline.svg)](https://codebase.helmholtz.cloud/dam-elbextreme/oxypom/-/pipelines)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](./LICENSES/Apache-2.0.txt)

# OxyPOM and DiaMO: simple models for dissolved oxygen and biogeochemistry

`OxyPOM` (**Oxygen and Particulate Organic Matter**) and `DiaMO` (**Diagnostic Model for Oxygen**) are two models that resolve dissolved oxygen dynamics implemented in FABM.

## Description

* `OxyPOM` simulates oxygen consumption and production in river based on [Holzwarth and Wirtz, 2018](https://doi.org/10.1016/j.ecss.2018.01.020), including key biogeochemical processes as photosynthesis, respiration, mineralization, and nitrification.

* `DiaMO` is a simplification of `OxyPOM` and calculates oxygen consumption and production using a statistical inspired model.

The code of these models is located in the directory `./src` (e.g., `./src/oxypom` and `./src/diamo`), and future code developed as part of this model should be here included.

Together with `OxyPOM` and `DiaMO`, this repository includes the model `oxypom/light`: a second order correction for the calculation of photosynthetically active radiation depth profiles.


## Requirements

* This model requires:
  - `FABM` (v1 or above) available in [fabm github](https://github.com/fabm-model/fabm/).
  It can be cloned using `git clone https://github.com/fabm-model/fabm.git fabm`.

* The physical driver:
  - `GOTM` (v6.0 latest stable release) available in [gotm github](https://github.com/orgs/gotm-model/repositories).
  It can be cloned using via `git clone --recursive https://github.com/gotm-model/code.git -b v6.0 gotm6`.

The following is not required to build and run the model but it is for running the test case:

* The script for downloading forcing and validation data requires the following shell commands:
  - `wget`
  - `unzip`
  - `sed`

* The scripts for generating forcing files setup and plotting routines for model validation require:
  -`R` (v4.3 or above) available in [r home](https://www.r-project.org/) with the library `ncdf4` installed.

## Testcases

We provide the model with a testcase in the directory `./testcases`.
New testcases for **OxyPOM** and **DiaMO** should be included in a single directory within `./testcases`.
Currently, we include the testcase "Estuary".

### Testcase Estuary

This setup uses the physical driver `GOTM` to simulate the water column dynamics in the Elbe estuary in 2005-2024.

1. To run the testcase go to the directory `.\testcases`.

The model is build with the script `gotm-installation.sh`, in where these variables must be defined:
    - `GOTM_DIR` base directory of GOTM source code
    - `FABM_DIR` base directory of FABM source code
    - `OXYPOM_DIR` base directory of OxyPOM source code

By default they are:

    ``` bash
    export GOTM_DIR=$HOME/tools/gotm6
    export FABM_DIR=$HOME/tools/fabm/fabm
    export OXYPOM_DIR=$HOME/tools/oxypom/src
    ```

2. The script `gotm-installation.sh` creates the directory `.\build` with the building files, and a copy of `gotm` executable in the `.\estuary` directory.
    Now move to the directory `.\estuary`.

3. The script `get_data.sh` download and unzip the forcing and validation data from [kuestendaten.de](https://www.kuestendaten.de) in a newly created directory `.\data`.
    The downloaded files are used under license [DL-DE->Zero-2.0](https://www.govdata.de/dl-de/zero-2-0).

4. The script `setup_data.R` formatted the data to be read by `GOTM`. It generates the file `meteofile.csv`.

5. Run the model with `./gotm`. It generates the files `output.nc` and `restart.nc`.

6. The script `plot_output.R` analyses the model output.

If everything is correct, the figure `estuary_validation.png` should be produced.
It displays a comparison of simulation and data for temperature and dissolved oxygen values.

The entire procedure is included in `./testcases/run-estuary-testcase.sh`.

### Testcase light

This setup uses the physical driver `GOTM` to simulate the water column dynamics in the Elbe estuary in 2005-2024 and compares the default light implementation with the provided by `oxypom/light`.

Follow steps 1-2 of the estuary testcase.

Now move to the directory `.\light`.

* The script `model_comparison.R` analyses the model output.

If everything is correct, the figure `light_validation.png` should be produced.
It displays a comparison of simulations using the default light implementation with the provided by `oxypom/light`.

The entire procedure is included in `./testcases/run-light-testcase.sh`.

## License

Apache-2.0 (OxyPOM and DiaMo)
GPL-2.0-only (light)

## Project status

This is part of the `DAM-ElbeXtreme` project.