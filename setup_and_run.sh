#!/bin/bash

set -e

# use as: setup_and_run.sh lab3_condition:no_globl.s

if ! [ -d ./results/ ]; then
mkdir results
fi

# clone repo
if ! [ -d ./workshop_risc-v/ ]; then
echo "Cloning risc-v repo"
git clone https://github.com/moevm/workshop_risc-v.git
fi

# copy scripts
cp -f run_load.sh ./workshop_risc-v/
cp -f analyze_*.py ./workshop_risc-v/
cp -f load.sh ./workshop_risc-v/tst/

cd workshop_risc-v
# build image
./scripts/build.sh
./run_load.sh $*

cp -f ./*.png ../results/
cp -f ./*.log ../results/
rm ./*.png ./*.log
cd -

echo "Done! Data placed in ./results"
