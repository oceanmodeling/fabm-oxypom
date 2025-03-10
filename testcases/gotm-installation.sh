# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

export GOTMDIR=$HOME/tools/gotm/code
export FABMDIR=$HOME/tools/fabm/fabm
export DOBGCPDIR=$HOME/tools/dobgcp

mkdir -p ./build/gotm
cd ./build/gotm
cmake -S $GOTMDIR -DGOTM_USE_FABM=ON -DFABM_BASE=$FABMDIR -DFABM_INSTITUTES="examples;gotm;dobgcp" -DFABM_DOBGCP_BASE=$DOBGCPDIR 
make 
make install

cd ../../

ln ./build/gotm/gotm ./estuary/gotm
ln ./build/gotm/gotm ./river/gotm


