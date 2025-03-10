# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

export GOTMDIR=$HOME/tools/gotm/code
export FABMDIR=$HOME/tools/fabm/fabm
export DOBGCPDIR=$HOME/tools/dobgcp-surface


## compiling
mkdir -p ./build/fabm-0d
cd ./build/fabm-0d
cmake -S $FABMDIR/src/drivers/0d -DFABM_HOST=0d -DGOTM_BASE=$GOTMDIR -DFABM_INSTITUTES="examples;gotm;dobgcp" -DFABM_DOBGCP_BASE=$DOBGCPDIR 
make
make install
