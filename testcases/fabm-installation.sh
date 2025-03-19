# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

export GOTM_DIR=$HOME/tools/gotm6
export FABM_DIR=$HOME/tools/fabm/fabm
export OXYPOM_DIR=$HOME/tools/oxypom/src

mkdir -p ./build/fabm-0d
cd ./build/fabm-0d
cmake -S $FABM_DIR/src/drivers/0d -DFABM_HOST=0d -DGOTM_BASE=$GOTM_DIR -DFABM_INSTITUTES="examples;gotm;oxypom" -DFABM_OXYPOM_BASE=$OXYPOM_DIR 
make
make install

cd ../../