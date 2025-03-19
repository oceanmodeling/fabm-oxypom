# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

export GOTM_DIR=$HOME/tools/gotm6
export FABM_DIR=$HOME/tools/fabm/fabm
export OXYPOM_DIR=$HOME/tools/oxypom/src

mkdir -p ./build/gotm
cd ./build/gotm
cmake -S $GOTM_DIR -DGOTM_USE_FABM=ON -DFABM_BASE=$FABM_DIR -DFABM_INSTITUTES="examples;gotm;oxypom" -DFABM_OXYPOM_BASE=$OXYPOM_DIR 
make 
make install

cd ../../

ln -f ./build/gotm/gotm ./estuary/gotm
ln -f ./build/gotm/gotm ./light/gotm
