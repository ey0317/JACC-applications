#!/bin/bash

export JULIA_DEPOT_PATH=$HOME/.julia-JACC 
ROCM_VER=7.2.0

# load required modules only 
module purge 
module load Core
module load PrgEnv-gnu 
module load rocm/$ROCM_VER
module load julia 

export ROCM_PATH=/opt/rocm-$ROCM_VER

APPS=(
        "BabelStream/JACC"
        "miniBUDE"
)

for APP in "${APPS[@]}"; do 
	# specify project directory for each app 
	PROJ_DIR=$HOME/JACC-applications/$APP

	# remove existing generated manifest and local preferences 
	rm -fr "$PROJ_DIR/Manifest.toml" 
	rm -fr "$PROJ_DIR/LocalPreferences.toml" 

	# configure julia 
	julia --project="$PROJ_DIR" -e 'using Pkg; Pkg.instantiate()' 
	julia --project="$PROJ_DIR" -e 'using JACC; JACC.set_backend("AMDGPU")'
	julia --project="$PROJ_DIR" -e 'using Pkg; Pkg.precompile()'
done 
