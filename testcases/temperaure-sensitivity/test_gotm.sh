# SPDX-FileCopyrightText: 2026 Helmholtz-Zentrum hereon GmbH
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

export GOTMDIR=$HOME/tools/gotm6
export FABMDIR=$HOME/tools/fabm/fabm
export OXYPOMDIR=$HOME/tools/dobgcp/src    

mkdir -p ./build
cd ./build
cmake -S $GOTMDIR -DGOTM_USE_FABM=ON -DFABM_BASE=$FABMDIR -DFABM_INSTITUTES="gotm;iow;oxypom" -DFABM_OXYPOM_BASE=$OXYPOMDIR    
make    
make install

cd ../

ln -f ./build/gotm ./gotm

ln -sf fabm_uniform.yaml fabm.yaml
./gotm
mv output.nc output_uniform.nc


ln -sf fabm_sensitive.yaml fabm.yaml
./gotm
mv output.nc output_sensitive.nc

Rscript plot_output.R    