---
title: "DO+BGC (Dissolved Oxygen and BioGeoChemistry)"
tags:
  - FABM
  - Biogeochemistry
  - Oxygen
  - ElbeXtreme
authors:
  - name: Ovidio García-Oliva
    orcid: 0000-0003-3483-6036
    affiliation: 1
    corresponding: true
  - name: Carsten Lemmen
    orcid: 0000-0003-3483-6036
    affiliation: 1
affiliations:
  - name: Helmholtz-Zentrum Hereon, Institute of Coastal Systems - Modeling and Analysis, Germany, carsten.lemmen@hereon.de
    index: 1
date: 11 March 2025
year: 2025
bibliography: paper.bib
SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
SPDX-License-Identifier: CC-BY-4.0
---

# Summary
DO+BGC (Dissolved Oxygen and BioGeoChemistry) is a collection of aquatic biogeochemical models that consider key processes for dissolved oxygen (DO) dynamics, such as re-aeration, mineralization, and primary production.
It includes two main components: OxyPOM (Oxygen and Particulate Organic Matter) and DiaMo (Diagnostic Model).
Both models are implemented in the Fortran-based Framework for Aquatic Biogeochemical Models (FABM), which enables their deployment in different physical drivers in realistic and idealized applications.
Additional routines for calculating the attenuation of photosynthetically active radiation are included.
<!-- 2 paragraph summary -->
The processes represented in DO+BGC enable studying DO in fresh, marine, and transitional waters.
With this model, we include a testcase for simulating DO in Cuxhaven Station in the Elbe estuary from 2005 to 2024.
This testcase uses the General Ocean Turbulence Model (GOTM) [@Burchard2002] to simulate vertical 1D hydrodynamics with realistic parameterization for tidal dynamics [@Reese2024] and scripts for downloading real meteorological forcing from [kuestendaten.de](https://www.kuestendaten.de).

# Statement of need

Dissolved oxygen (DO) is a key variable for water quality assessment and the study of the ecological state of running and standing aquatic ecosystems [@EC2006].
Models for DO in waters are thus necessary.
Most models, however, describe DO dynamic as a side product of more or less complex biotic and abiotic dynamics.
DO+BGC focuses on the key processes that produce or consume oxygen while removing the complexity of adjacent processes.
OxyPOM was implemented by @Holzwarth2018 using Delwaq [@Blaw2009] and coupled with Untrim [@Sehili2014] as the physical driver in an idealization of the Elbe estuary.
This implementation, however, was limited to this specific application and thus lacked portability.
Implementing this model in the Fortran-based Framework for Aquatic Biogeochemical Models (FABM) [@Bruggeman2014], OxyPOM can be used with many physical drivers; in different geographical domains; and coupled with other biogeochemical models.
OxyPOM uses vertically explicit formulations for re-aeration, primary production, and light attenuation, which are lacking in the @Holzwarth2018 implementation.
Additionally, DO+BGC includes DiaMo as a simplified model for quick assessments for DO dynamics in applications where modelling complete bio-geochemical dynamics is not needed, and a model for light with a second-order correction for attenuation of photosynthetically active radiation in water.

# Key features of the model

## OxyPOM: Oxygen and Particulate Organic Matter
The model OxyPOM resolves the dynamics of
dissolved oxygen (DO),
particulate organic matter (POM)--fresh and refractory--,
particulate inorganic silicon,
dissolved organic matter (DOM),
inorganic dissolved nutrients,
and two micro-algae classes (ALGi).
DO dynamics is based on a mass balance equation accounting for re-aeration and photosynthesis as oxygen sources, and respiration, mineralization and nitrification as sinks:

\begin{equation}
 \frac{d \textrm{DO}}{dt} = \textrm{re-aeration} + (\textrm{photosynthesis} - \textrm{respiration}) - \textrm{mineralization} + \textrm{nitrification}.
 \label{eq:do}
\end{equation}

This equation is applied to each water volume considered by the physical driver.
Re-aeration occurs in the surface-most layer as a function of temperature, salinity and wind speed.
Photosynthesis is limited by nutrient concentration and light intensity in each layer.
Respiration includes oxygen consumption for both micro-algae classes.
Mineralization is the oxygen consumed to transform matter from organic to inorganic forms.
Nitrification is the oxygen consumed to oxidize ammonia into nitrate.
Temperature-dependent rates limit these processes.

In OxyPOM, POM and DOM have an explicit elemental composition (carbon, nitrogen and phosphorus).
POM is present in two qualities, fresh and refractory, which transition in the sequence fresh $\rightarrow$ refractory $\rightarrow$ dissolved. 
POM and DOM mineralize to inorganic dissolved inorganic nutrients: nitrogen and ortho-phosphate.
Dissolved inorganic nitrogen is further subdivided into ammonium and nitrate.
Ammonia transitions to nitrate--nitrification-- as a function of DO.
Silicon is present in dissolved--bio-available-- and particulate mineral forms.
The two micro-algae classes (ALG1 and ALG2) have growth rates that depend on temperature, light intensity and inorganic nutrient concentrations.
Both ALG1 and ALG2 growth depend on dissolved nitrogen and ortho-phosphate concentrations, and only ALG1 depends on free silicate, thus representing diatoms.
Microalgae uptake dissolved inorganic nutrients and release dissolved nutrients when they die with a temperature-dependent mortality rate.

While the full description of the processes in OxyPOM is available in @Holzwarth2018, some changes were required for a vertically explicit implementation within FABM:

  1. Re-aeration is calculated as surface oxygen transference using saturation concentration as a function of temperature, salinity and wind speed [@Weiss1970].
 This approach is commonly used in other models, such as ERSEM [@Butenschon2016].

  2. Light limitation for photosynthesis is calculated with an exponential saturation [@Platt1980].

  3. Settling velocities are set constant, and vertical redistribution of matter is carried out by the physical driver.

We validate DO+BGC models in the Cuxhaven station in the Elbe estuary, where OxyPOM shows high skill by reproducing surface DO.

![Validation of OxyPOM model with the testcase estuary.](figure1.png){ width=99% }\

## DiaMo: Diagnostic model

DiaMo resolves the dynamics of DO, living and non-living organic particulate carbon forms (phytoplankton and detritus, respectively) under the assumption that light, not nutrients, is the limiting factor for primary production.
DiaMo is thus a carbon-based implementation.
DO is solved with the mass balance equation of OxyPOM (\autoref{eq:do}), setting nitrification to zero.
The complete system is represented as

\begin{eqnarray}
 \frac{d \textrm{Phytoplankton}}{dt} &=& \textrm{photosynthesis} - \textrm{respiration} - \textrm{aggregation} \\
 \frac{d \textrm{Detritus}}{dt} &=& \textrm{aggregation} - \textrm{mineralization} \\
 \frac{d \textrm{DO}}{dt} &=& \textrm{re-aeration} + (\textrm{photosynthesis} - \textrm{respiration}) - \textrm{mineralization}.
\end{eqnarray}

In DiaMo, aggregation rate is a mortality term for phytoplankton [@Maerz2009].
As in OxyPOM, all rates in DiaMO are temperature-dependent.

## Light

As part of the vertical-explicit formulation, a key feature of DO+BGC is an alternative to the FABM implementation of the light model used by GOTM [@Burchard2002].
While the default light model assumes that the photosynthetically active radiation (PAR) in a vertical layer $z$ of thickness $\Delta z$ is in the centre of the layer, the light model included in DO+BGC calculates PAR in the representative depth $\bar{z}$, which satisfies the mean value theorem.
PAR evaluated at $\bar{z}$ is thus the mean PAR intensity on the layer.
Since this calculation can be computationally expensive to evaluate, first- and second-order approximations are possible.
The first-order solution is equal to the centre of the layer $z + 0.5 \cdot \Delta z$, and the second-order approximation is

\begin{equation}
 \bar{z} = z + \frac{1}{2} \Delta z - \frac{\alpha}{3} \Delta z ^ 2,
 \label{eq:secondorder}
\end{equation}

where $\alpha$ is the light extinction coefficient for the layer, accounting for physical and biological light absorption, assuming an exponential light decay.

# Model documentation and license

The model is documented in short form in the README section of the repository and a complete description of the science behind OxyPOM is in @Holzwarth2018.
Data from third parties are not included with the model, scripts for their download are however included.
Downloaded data are licensed under a multitude of open source licenses.
The model, its results and own proprietary data are released under open source licenses, mostly Apache 2.0, GPL-2.0-only and CC-by-SA 4.0.
A comprehensive documentation of all licenses is provided via REUSE Software.

# Acknowledgements

The development of this model was made possible by the grant no. 03F0954D of the BMBF as part of the DAM mission ‘mareXtreme’, project ElbeXtreme.
<!-- We are grateful for the open source community that facilitated this research, amongst them the developers of and contributors to FABM, GOTM, Python, R, pandoc, and LaTeX. -->

# References
