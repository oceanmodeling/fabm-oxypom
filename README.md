!! SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
!! SPDX-License-Identifier: CC0-1.0
!! SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

# DO+BGC (Dissolved Oxygen and BioGeoChemistry)

**DO+BGC** is a family of models for Dissolved Oxygen Dynamics plus simple biogeochemistry implemented in `FABM`.

## Description
**DO+BGC** includes:

* `OxyPOM` (**Oxygen + Particulate Organic Matter**): Simulates oxygen consumption and production in river based on [Holzwarth and Wirtz, 2018](https://doi.org/10.1016/j.ecss.2018.01.020). 
* `DiaMo` (**Diagnostic Model**): Simulates oxygen consumption and production Using a statistical inspired model. 

## Installation and usage
* Requires the last version of `FABM` and the last version of `GOTM`.
* you can run the testcases by running the installation scripts `gotm-installation.sh`   
* Remember to add this repository in the compilation flags (the `cmake`) in the `Makefile`. 

## Testcase
Here I include a testcase using `GETM 2D` as physical driver for Tidal Elbe + Elbe Estuary in 2011.
Just soft link the files `./testcase/rivers.u_020e-2.bgc.nc` as `rives.nc` and `fabm.dobgcp.yaml` as `fabm.yaml` into the `GETM 2D` setup.

## To do

- [x] Is the `meteo.nc` file available.
- [x] Are the boundary files properly formatted (`bdy*.nc`)?


## License
CC0-1.0

## Project status
This is part of the `DAM-ElbeXtreme` project.