---
title: "DO+BGC (Dissolved Oxygen and BioGeoChemistry)"
tags:
  - FABM
  - Biogeochemistry
  - Oxygen
  - ElbeXtreme
authors:
  - name: Ovidio García-Oliva
    orcid: 0000-0001-6060-2001
    corresponding: true
  - name: Carsten Lemmen
    orcid: 0000-0003-3483-6036
affiliations:
  - name: Helmholtz-Zentrum Hereon, Institute of Coastal Systems - Modeling and Analysis, Germany, carsten.lemmen@hereon.de
date: 12 March 2025
year: 2025
bibliography: paper.bib
SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
SPDX-License-Identifier: CC-BY-4.0
#logo_path: ./logo_large.jpg
---

# Summary

Dissolved Oxygen and BioGeoChemistry is a family of models that simulate the dynamics of dissolved oxygen and other biogeochemical variables in aquatic systems. The models are implemented in the Framework for Aquatic Biogeochemical Models (FABM, [@Bruggeman2014]) and are designed to be coupled with hydrodynamic models -- so-called hosts -- to simulate the interactions between physical and biogeochemical aquatic processes. The models can be used to study the effects of environmental changes, such as eutrophication, climate change, and pollution, on the biogeochemistry of aquatic systems, and especially on the oxygenation status of a system.

<!-- 2 paragraph summary -->

# Statement of need

There exist many implementations of aquatic biogeochemical models, most of them, however, are either integrated into more complex ecological models like ERGOM [@Neumann2002]or ICM [@XXX], or they have a focus on sediment biogeochemical processes like OmexDia [@Soetaert1998].  The two models here fill an important cap in the suite of available biogeochemical models as they focus on dissolved oxygen, (1) as a simple diagnostic, which has been demonstrated to be sufficient for many local processes and (2) as a simple dynamic model, which in addition includes ..., and has been demonstrated to describe oxygen in a river-estuary gradient.


## Key features of the diagnostic oxygen model (DiaMo)

The model simulates biogeochemical processes in an aquatic system by computing the temporal changes of three state variables: phytoplankton concentration (`PHY`), detritus concentration (`DET`), and dissolved oxygen (`OXY`). These changes are driven by the environmental conditions temperature (`temp`), photosynthetic light availability (`par`), water depth (`depth`), salinity (`salinity`), and wind speed (`wind`).

The **background light attenuation** is computed based on water clarity and suspended inorganic material (`SIM`): 

$$
\text{attenuationBack} = \text{attenuationWater} + \text{attenuationSIM} \cdot \text{SIM}
$$ 

Phytoplankton *growth* is modeled using a temperature-dependent formulation and is limited by available light:

$$
\text{synthesis} = \text{synthesisRef} \cdot \text{synthesisQ10}^{(\text{temp} - \text{tempRef})} \cdot \left(1 - e^{-\text{synthesisPar} \cdot \text{par}}\right) \cdot \text{PHY}
$$

This equation captures the **temperature effect**, using a reference growth rate (`synthesisRef`) modified by a Q10 temperature coefficient and the **light dependency**, represented by an exponential function of `par`, ensuring saturation effects.

Phytoplankton **respiration** is modeled as a temperature-dependent loss process:

$$
\text{respiration} = \text{respirationRef} \cdot \text{respirationQ10}^{(\text{temp} - \text{tempRef})} \cdot \text{PHY}
$$

Phytoplankton can **aggregate** to larger particles that contribute to detritus. This process depends on phytoplankton concentration, temperature, and available suspended material:

$$
\text{aggregation} = \text{aggregationRef} \cdot \text{aggregationQ10}^{(\text{temp} - \text{tempRef})} \cdot \text{PHY} \cdot \left(\text{DET} + k_{\text{SIM}} \cdot \text{SIM} \cdot e^{-\text{aggregationPar} \cdot \text{par}}\right)
$$

Detritus is **broken down** by microbial activity, which is also temperature-dependent:

$$
\text{degradation} = \text{degradationRef} \cdot \text{degradationQ10}^{(\text{temp} - \text{tempRef})} \cdot \text{DET}
$$

The time derivatives of the state variables are computed as follows.

$$
\frac{d\text{PHY}}{dt} = \text{synthesis} - \text{respiration} - \text{aggregation}
$$

$$
\frac{d\text{DET}}{dt} = \text{aggregation} - \text{degradation}
$$

$$
\frac{d\text{OXY}}{dt} = \text{oxygenation} + k_{\text{OXY}} \cdot (\text{synthesis} - \text{respiration} - \text{degradation})
$$


# Notable programming and software development features


# Model documentation and license 

# Acknowledgements

The models are being developed and applied in the context of the ElbeXtreme project, which aims to understand the impacts of extreme events on the biogeochemistry of the Elbe estuary. -->

<!--We acknowledge contributions from W. Nikolaus Probst, Marie Ryan, Jieun Seo, Verena Mühlberger and Kai W. Wirtz for providing feedback, data, fruitful discussions and for contributing to the ODD document. We thank all members of the MuSSeL consortium making this software relevant in a research context. The development of the model was made possible by the grants 03F0862A, 03F0862C, 03F0862D, 03F0862E "Multiple Stressors on North Sea Life" (MuSSeL) within the 3rd Küstenforschung Nord-Ostsee (KüNO) call of the Forschung für Nachhaltigkeit program of the Germany Bundesministerium für Bildung und Forschung (BMBF). We are grateful for the open source community that facilitated this research, amongst them the developers of and contributors to NetLogo, Python, R, pandoc, and LaTeX. -->

# References