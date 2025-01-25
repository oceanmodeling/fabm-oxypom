# DO+BGC (Dissolved Oxygen and BioGeoChemistry)

**DO+BGC** is a `FABM` model for Dissolved Oxygen Dynamics plus simple biogeochemistry.

## Description
This model simulates
This is based on [Holzwarth and Wirtz, 2018](https://doi.org/10.1016/j.ecss.2018.01.020). 

## Installation and usage
* This model requires the nutrient and detritus models available in `fabm/src/models/examples`.
* Remember to add this repository in the compilation flags (the `cmake`) in the `Makefile`. 
* Here I include a testcase using `GETM 2D` as physical driver for Tidal Elbe + Elbe Estuary (2011).

## License
CC0-1.0

## Project status
This is part of the `DAM-ElbeXtreme` project.