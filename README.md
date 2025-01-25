# DO+BGC (Dissolved Oxygen and BioGeoChemistry)

***DO+BGC*** is a `FABM` model for Dissolved Oxygen Dynamics plus simple biogeochemistry.

## Description
This model simulates Dissolved Oxygen dynamics plus a simplified biogeochemistry pelagic model based on [Holzwarth and Wirtz, 2018](https://doi.org/10.1016/j.ecss.2018.01.020), replacing depth-averaged formulations by depth-explicit processes.
Specifically, reaeration rates is changed to surface flow formulation similar to the used in `ERSEM`. 

This model includes:

* Dissolved Oxygen.
* Three nutrient species (nitrogen, phosphorus, and silicon).
* Two algal species, one depending on silicon.
* Two types of Particular Organic Matter.
* One type of Dissolved Organic Matter.
* Inorganic silicon.

## Installation and usage

* Remember to add this repository in the compilation flags (the `cmake`) in the `Makefile`. 

## Testcase
Here I include a testcase using `GETM 2D` as physical driver for Tidal Elbe + Elbe Estuary in 2011.
Just soft link the files `./testcase/rivers.u_020e-2.bgc.nc` as `rives.nc` and `fabm.dobgcp.yaml` as `fabm.yaml` into the `GETM 2D` setup.

## To do

[ ] Is the `meteo.nc` file available.
[ ] Are the boundary files properly formatted (`bdy*.nc`)?


## License
CC0-1.0

## Project status
This is part of the `DAM-ElbeXtreme` project.