# SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>
# SPDX-FileContributor Carsten Lemmen <carsten.lemmen@hereon.de>

test -d "$GOTM_BASE" && GOTM_DIR="$GOTM_BASE"
test -d "$FABM_BASE" && FABM_DIR="$FABM_BASE"
test -d "$FABM_OXYPOM_BASE" && OXYPOM_DIR="$FABM_OXYPOM_BASE"

export GOTM_DIR="${GOTM_DIR:-$HOME/tools/gotm6}"
export FABM_DIR="${FABM_DIR:-$HOME/tools/fabm/fabm}"
export OXYPOM_DIR="${OXYPOM_DIR:-$HOME/tools/oxypom/src}"

export BUILD_DIR=$PWD/build/gotm

mkdir -p $BUILD_DIR
cmake -S $GOTM_DIR -B $BUILD_DIR -DGOTM_USE_FABM=ON \
  -DFABM_BASE=$FABM_DIR -DFABM_INSTITUTES="examples;gotm;oxypom" -DFABM_OXYPOM_BASE=$OXYPOM_DIR/src \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build $BUILD_DIR --target all

ln -sf $BUILD_DIR/gotm ./estuary/gotm
ln -sf $BUILD_DIR/gotm ./light/gotm
