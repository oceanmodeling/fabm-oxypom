## SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
## SPDX-License-Identifier: CC0-1.0
## SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

add_library(fabm_models_dobgcp OBJECT
            dobgcp_model_library.F90
            dobgcp.F90
           )

add_dependencies(fabm_models_dobgcp fabm_base)
