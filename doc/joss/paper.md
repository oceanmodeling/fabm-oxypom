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
DO+BGC (Dissolved Oxygen and BioGeoChemistry) is a collection of aquatic bio-geochemical models that considers key processes for dissolved oxygen (DO) dynamics.
It includes two main components: OxyPOM (Oxygen and Particulate Organic matter) and DiaMo (Diagnostic Model).
Both models are implemented in the Fortran-based Framework for Aquatic Biogeochemical Models (FABM) enabling their deployment and application in different physical drivers in realistic and idealized applications.
Additional routines for calculating the attenuation of photosynthetically active radiation are included.
<!-- 2 paragraph summary -->
The processes represented in DO+BGC makes it ideal to study DO in fresh, marine, and transitional waters.
With this model, we include a testcase for simulating DO+BGC in the Cuxhaven station in the Elbe estuary.
This testcase uses GOTM `[@GOTM]` to simulate vertical 1D hydrodynamics and includes realistic parameterization for tidal dynamics `[@Reese2024]` and scripts for downloading  real meteorological forcing from [kuestendaten.de](https://www.kuestendaten.de).

# Statement of need

Dissolved oxygen (DO) is a key variable to assess water quality and general ecological state of running and standing aquatic ecosystems .
Moreover, DO can mediate between meteorological extremes and biological effects, e.g. heatwaves in estuaries `[@Tassone2022]`.
A model similar to OxyPOM was implemented by `@Holzwarth2018a` using Delwaq `[@Casulli2008]` and coupled to Untrim `[@Sehilli2014]` as physical driver in an idealization of the Elbe estuary.
This implementation, however, was limited to this specific application, and thus lacking portability.
By implementing this model in the Fortran-based Framework for Aquatic Biogeochemical Models (FABM) `[@Bruggeman2014]`, OxyPOM can be used with many different physical drivers, geographical domains, and coupled with other bio-geochemical models.
OxyPOM uses vertically-explicit formulations for re-aeration and light attenuation, which are lacking in the `@Holzwarth2018a` implementation.
Additionally, DO+BGC includes DiaMo as a simplified model for quick assessments for DO dynamics in applications where modelling a complete bio-geochemical dynamics is not required, and light a second order correction for light attenuation in water.

# Key features of the model

OxyPOM resolves the dynamics of 
dissolved oxygen (DO),
particulate organic matter (POM)--fresh and refractory--,
particulate inorganic silicon,
dissolved organic matter (DOM),
inorganic nutrients,
and two micro-algae classes (ALGi).
DO dynamics is based on a mass balance equation accounting for re-aeration and photosynthesis as oxygen sources, and respiration, mineralization and nitrification as sinks:

\begin{equation}
  \frac{d DO}{dt} = (re-aeration + photosynthesis) -  (respiration + mineralization + nitrification).
  \label{eq:do}
\end{equation}

POM and DOM have explicit elemental composition (carbon, nitrogen and phosphorus).
POM is present in two qualities, fresh and refractory, which transition   
Inorganic nutrients consist on nitrogen, ortho-phosphate and free silicate.
Dissolved inorganic nitrogen is further subdivided into ammonium and nitrate.
The two micro-algae classes (ALG1 and ALG2) have a growth rate dependent on light intensity and inorganic nutrient concentrations.
Both ALG1 and ALG2 growth depend on dissolved nitrogen and ortho-phosphate concentrations.
Only ALG1 depends on free silicate, thus representing diatoms.

![Validation of OxyPOM model with the testcase estuary.](figure1.png){ width=99% }

DiaMo resolves the dynamics of DO, living and not-living organic particulate carbon (micro-algae and detritus, respectively) under the assumption that light and not nutrients are the limiting factor for primary production.
DiaMo is thus a carbon-based implementation.
DO is solved with the mass balance equation of OxyPOM (Eq.~\ref{eq:do}), setting nitrification to zero.

As part of the vertical-implicit formulation, a key feature of DO+BGC is an alternative to the FABM implementation of the light model used by the General Ocean Turbulence Model (GOTM) [@GOTM].
While the default light model assumes that PAR in a vertical layer $z$ of thickness $\Delta z$ is located in the center of the layer, thus in $z + 0.5 \cdot \Delta z$, the light model included in DO+BGC calculate PAR in the representative depth $\bar{z}$ which satisfies the mean value theorem

\begin{equation}
  \frac{\int_{z}^{z+\Delta z} I(z')\cdot dz'}{\Delta z} = I(\bar{z}),
  \label{eq:cvt}
\end{equation}

where $I(z')$ is an exponential decay profile according to Beer-Lambert law with attenuation coefficient $\alpha$--accounting for physical and biological absorption--

\begin{equation}
  I(z') = I(z)\cdot e^{-\alpha \cdot z'}. 
  \label{eq:bl}
\end{equation}

The exact solution for the representative depth $\bar{z}$ is

\begin{equation}
  \bar{z} = z -\frac{1}{\alpha}\log\left( \frac{1-e^{-\alpha \cdot \Delta z}}{\alpha \cdot \Delta z} \right)
  \label{eq:exact}
\end{equation}

As this function is computationally expensive to evaluate, first- and second-order approximations are possible.
The first order solution is equal to the center of the layer

\begin{equation}
  \bar{z} = z + \frac{1}{2} \Delta z,
  \label{eq:firstorder}
\end{equation}

and the second order approximation is

\begin{equation}
  \bar{z} = z + \frac{1}{2} \Delta z - \frac{\alpha}{3} \Delta z ^ 2.
  \label{eq:secondorder}
\end{equation}

# Notable programming and software development features



# Model documentation and license

The model is documented in short form in the README section of the repository and a complete description of the science behind OxyPOM is in `@Holzwarth2018a`.
Data from third parties are not included with the model, scripts for their download are however included.
Downloaded data are licensed under a multitude of open source licenses.
The model, its results and own proprietary data are released under open source licenses, mostly Apache 2.0, GPL-2.0-only and CC-by-SA 4.0.
A comprehensive documentation of all licenses is provided via REUSE Software.

# Acknowledgements

The development of this model was made possible by the grant no. 03F0954D of the BMBF as part of the DAM mission ‘mareXtreme’, project ElbeXtreme.
<!--We acknowledge contributions from W. Nikolaus Probst, Marie Ryan, Jieun Seo, Verena Mühlberger and Kai W. Wirtz for providing feedback, data, fruitful discussions and for contributing to the ODD document. We thank all members of the MuSSeL consortium making this software relevant in a research context. The development of the model was made possible by the grants 03F0862A, 03F0862C, 03F0862D, 03F0862E "Multiple Stressors on North Sea Life" (MuSSeL) within the 3rd Küstenforschung Nord-Ostsee (KüNO) call of the Forschung für Nachhaltigkeit program of the Germany Bundesministerium für Bildung und Forschung (BMBF). We are grateful for the open source community that facilitated this research, amongst them the developers of and contributors to NetLogo, Python, R, pandoc, and LaTeX. -->

# References
