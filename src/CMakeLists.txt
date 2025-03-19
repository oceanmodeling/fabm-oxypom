## SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
## SPDX-License-Identifier: CC0-1.0
## SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

add_library(fabm_models_oxypom OBJECT
            oxypom_model_library.F90
            oxypom/oxypom.F90
            diamo/diamo.F90
            light/light.F90
           )

add_dependencies(fabm_models_oxypom fabm_base)
