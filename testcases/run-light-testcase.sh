# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

bash gotm-installation.sh
cd light
Rscript -e 'options(repos=c(CRAN="https://cloud.r-project.org")); if(!requireNamespace("ncdf4",quietly=TRUE)) install.packages("ncdf4"); library(ncdf4)'
Rscript model_comparison.R
cd ..