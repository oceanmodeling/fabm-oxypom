<!---
SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
SPDX-License-Identifier: CC0-1.0
SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>
-->

# Testcase for OxyPOM: temperature sensitivity

This directory includes a testcase for uniform vs. process-specific temperature sensitivity in an idealized case.
It includes:

* configuration files
* data for running the model
* scripts for analyzing the data

Just run `bash test_gotm.sh`, if successful, `output_uniform.nc` and `output_sensitive.nc` should be produced.

Typically, no editing is needed to any file as long as the environment variables `GOTMDIR`, `FABMDIR`, and `OXYPOMDIR` are correctly defined in.
Otherwise edit `test_gotm.sh` to the right directories.

The scripts `Q10_sensitivity.sh` runs the model for different Q10 values and produce several figures detailing the effect of varying Q10 in dissolved oxygen concentration and related processes.

## Configuration files

Three configuration files are required to set-up the simulation:

* `gotm.yaml`: physical configuration (coordinates, tidal components, depth, etc.) and location of forcing files.

* `fabm.yaml`: configuration (parameterization and initial conditions) of OxyPOM models.

* `output.yaml`: configuration for model output.

## Visualization scripts

The model results can be inspected in the figures:

* `comparison.pdf`: depth-time diagrams and relative error plots of state variables and oxygen-related processes.

* `flux.pdf`: oxygen flux related to re-aeration, photosynthesis, mineralization, respiration, and nitrification in absolute and relative terms.

* `Q10_simple plot.pdf`: temperature sensitivity of the used Q10 rule with different Q10 coefficients and phytoplankton growth rate.

* `Q10_difference_annual_mean_heatmap.pdf`: comparison of annual mean difference between uniform and process-specific temperature sensitivity.
  
* `Q10_difference_comparison.pdf`: comparison of differences between uniform and process-specific temperature sensitivity sorted by process.
  
* `Q10_difference_comparison_by_parameter.pdf`: comparison of differences sorted by parameter.
  
* `photo_sensitivity.pdf`: comparison of parameterizations to reproduce several photosynthesis responses to temperature (e.g., unimodal, sigmoidal, exponential).

## External data acquisition and management

Idealized forcing data (`.\data\meteofile.csv`) inspired in the Cuxhaven sampling station in the Elbe estuary is included.
Dinoflagellates growth rate data as function of temperature (`.\data\source2.csv`) is also provided.

## Licenses

Apache-2.0
CC0-1.0

## To do
