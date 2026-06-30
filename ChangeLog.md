<!--
SPDX-FileCopyrightText: 2025-2026 Helmholtz-Zentrum hereon GmbH
SPDX-License-Identifier: CC0-1.0
SPDX-FileContributor: Carsten Lemmen <carsten.lemmen@hereon.de>
-->

# Change log and release notes

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# Release notes for ongoing development

- no changes yet

# Release notes for version 2.0.2 (2026-06-30)

- Maintenance for CMake, directory names
- submission of revised version to Ecological Modelling
- Enforce par/I0 ≥ 0 when obtaining environment to prevent blowup with negative (missing_value) passed from SCHISM

### Changed
- Updated temperature sensitivity testcase
- Added -DCMAKE_POLICY_VERSION_MINIMUM=3.5 to Docker configuration



# Release notes for version 2.0.1 (2026-02-27)

- Added alkalinity as a new diagnostic variable
- Included a new testcase for temperature sensitivity
- Improved installation scripts for portability
- Updated documentation and fixed minor issues

# Release notes for version 2.0.0 (2025-09-03)

- Virus infection as a mortality for micro-algae
- Clean up unused variables
- Revised re-aeration routine
- Revised temperature-dependent mortality
- Revised stoichiometry for micro-algae

# Release notes for version 1.0.1 (2025-03-31)

- Cleanup of git history
- Simulation results available as artifacts
- Deposition on Zenodo

# Release notes for version 1.0.0 (2025-03-21)

- More complete metadata
- Homogenized documentation
- Submission to the Journal of Open Source Software (JOSS)
- Docker available at https://registry.hzdr.de/dam-elbextreme/oxypom/fabm:latest

# Release notes for version 0.9.1 (2025-03-21)

- Feature-complete version of the OxyPOM, DiaMO, and light FABM models,
- Test case for the Elbe estuary,
- Implementation of Good Modeling Practices,
- Rich software metadata.
