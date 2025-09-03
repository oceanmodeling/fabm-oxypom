<!--
SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
SPDX-License-Identifier: CC0-1.0
SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>
SPDX-FileContributor Carsten Lemmen <carsten.lemmen@hereon.de>
-->

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/10196/badge)](https://www.bestpractices.dev/projects/10196)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](./doc/contributing/code_of_conduct.md)
[![REUSE status](https://api.reuse.software/badge/github.com/fsfe/reuse-tool)](https://api.reuse.software/info/codebase.helmholtz.cloud/dam-elbextreme/oxypom)
[![Prettier style](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square)](https://github.com/prettier/prettier)
[![Pipeline](https://codebase.helmholtz.cloud/dam-elbextreme/oxypom/badges/main/pipeline.svg)](https://codebase.helmholtz.cloud/dam-elbextreme/oxypom/-/pipelines)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](./LICENSES/Apache-2.0.txt)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15111433.svg)](https://zenodo.org/records/15111433)

<!--
[![CodeFactor](https://www.codefactor.io/repository/github/platipodium/vinos/badge)](https://www.codefactor.io/repository/github/platipodium/vinos
[![Open Code](https://img.shields.io/badge/_%3C%2F%3E-open_code-92c02e?logo=gnometerminal&logoColor=lightblue&link=https://www.comses.net/resources/open-code-badge/)](LINK HERE)
[![JOSS status](https://joss.theoj.org/papers/84a737c77c6d676d0aefbcef8974b138/status.svg)](LINK HERE)
-->

# OxyPOM and DiaMO: simple models for dissolved oxygen and biogeochemistry

OxyPOM (**Oxygen and Particulate Organic Matter**) and DiaMO (**Diagnostic Model for Oxygen**) are aquatic biogeochemical models that consider key processes for dissolved oxygen (DO), such as re-aeration, mineralization, and primary production, in fresh, transitional and marine waters.
Both are implemented in the `Fortran`-based Framework for Aquatic Biogeochemical Models ([FABM](https://github.com/fabm-model/fabm/)) for interoperability in a variety of hydrodynamic models, in realistic and idealized applications, and for coupleability to other aquatic process models.

## Description

- `OxyPOM` simulates oxygen consumption and production in aquatic ecosystems [(Holzwarth and Wirtz, 2018)](https://doi.org/10.1016/j.ecss.2018.01.020) and resolves key biogeochemical processes as photosynthesis, respiration, mineralization, and nitrification.

- `DiaMO` is a simplification of `OxyPOM` useful when a complete representation of bio-geochemical dynamics is not needed,

The code of these models is located in the directory `./src` (e.g., `./src/oxypom` and `./src/diamo`), and future code developed as part of this model should be here included.

Together with `OxyPOM` and `DiaMO`, this repository includes the model `oxypom/light`: a second order correction for the calculation of photosynthetically active radiation depth profiles.

## Requirements

- This model requires:

  - `FABM` (v1 or above) available in [fabm github](https://github.com/fabm-model/fabm/).
    It can be cloned using `git clone https://github.com/fabm-model/fabm.git fabm`.

  - The physical driver:
    - `GOTM` (v6.0 latest stable release) available in [gotm github](https://github.com/orgs/gotm-model/repositories).
      It can be cloned using via `git clone --recursive https://github.com/gotm-model/code.git -b v6.0 gotm6`.

The following is not required to build and run the model but it is for running the test case:

- The script for downloading forcing and validation data requires the shell commands `wget`, `unzip`, and `sed`.

- The scripts for generating forcing files setup and plotting routines for model validation require `R` (v4.3 or above) available in [r home](https://www.r-project.org/) with the library [`ncdf4`](https://cran.r-project.org/web/packages/ncdf4/index.html) installed.

## Testcases

We provide the model with a testcase in the directory `./testcases`.
New testcases for **OxyPOM** and **DiaMO** should be included in a single directory within `./testcases`.
Currently, we include the testcase "Estuary".

### Testcase Estuary

This setup uses the physical driver `GOTM` to simulate the water column dynamics in the Elbe estuary in 2005-2024.

1. To run the testcase go to the directory `./testcases`.

The model is build with the script `gotm-installation.sh`, in where these variables must be defined: - `GOTM_DIR` base directory of GOTM source code - `FABM_DIR` base directory of FABM source code - `OXYPOM_DIR` base directory of OxyPOM source code

By default they are:

    ``` bash
    export GOTM_DIR=$HOME/tools/gotm6
    export FABM_DIR=$HOME/tools/fabm/fabm
    export OXYPOM_DIR=$HOME/tools/oxypom/src
    ```

2. The script `gotm-installation.sh` creates the directory `./build` with the building files, and a copy of `gotm` executable in the `./estuary` directory.
   Now move to the directory `./estuary`.

3. The script `get_data.sh` download and unzip the forcing and validation data from [kuestendaten.de](https://www.kuestendaten.de) in a newly created directory `./data`.
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

Now move to the directory `./light`.

- The script `model_comparison.R` analyses the model output.

If everything is correct, the figure `light_validation.png` should be produced.
It displays a comparison of simulations using the default light implementation with the provided by `oxypom/light`.

The entire procedure is included in `./testcases/run-light-testcase.sh`.

## License

Apache-2.0 (OxyPOM and DiaMo)

## Project status

This is part of the `DAM-ElbeXtgreme` project.

## Contributing and reporting

We recommend to use latest git commit an branch main version of the model.
We appreciate your feedback, bug reports and improvement suggestions on our GitLab [issue tracker](https://codebase.helmholtz.cloud/dam-elbextreme/oxypom/-/issues).
We also welcome your contributions, subject to our Contributor Covenant [code of conduct](https://codebase.helmholtz.cloud/dam-elbextreme/oxypom/-/blob/main/doc/contributing/code_of_conduct.md) and our [Contributor License Agreement](https://codebase.helmholtz.cloud/dam-elbextreme/oxypom/-/blob/main/doc/contributing/contributing-license.md).

The **best way to contribute** is by (1) creating a fork off our repository, (2) committing your changes on your fork and then (3) creating a pull request ("PR") to push your changes back to us.

To file an issue or to contribute, you are asked to (1) authenticate with an existing identity and (2) to register on the HIFIS GitLab instance and sign in.
When asked, click "Sign in with Helmholtz AAI".
On the following page "Login to Helmholtz AAI OAuth2 Authorization Server", search for one of your existing authentication providers (this may be your university, company, ORCID, GitHub, or many others) and provide their login credentials for authorization.
If you are not already registered on the HIFIS GitLab instance, a confirmation email will be sent to the primary email address registered with your authentication provider.
After clicking the confirmation link, you will also be asked to provide a name on this GitLab instance; this will be your nickname.
Help on this one-time registration process is available from [https://hifis.net/tutorial/2021/06/23/how-to-helmholtz-aai.html](https://hifis.net/tutorial/2021/06/23/how-to-helmholtz-aai.html).

## Building the package

To build a new package, after committing the changes:

  1. describe new, deprecated and changed features in `ChangeLog.md`.
  2. change the version value `VERSION=NEW_VERSION` in `Makefile`
  3. make the package, i.e. run `make version`
  4. create a new version tag with `git tag vNEW_VERSION`
  5. push your changes
