#!/bin/bash

set -x

workdir=$(pwd)

echo "workdir: $workdir"
echo "args: $@"
ls -l

proc=$1
seed=$2
nevts=$3
shower=$4

# run MadGraph event generation
source /cvmfs/sft.cern.ch/lcg/views/LCG_100/x86_64-centos7-gcc9-opt/setup.sh
MGDIR=MYTOOLS/madgraph/LCG100/MG5_aMC_v3_1_1

tar -xf ${proc}.tar.gz
rm -rf ${proc}/Events/*

# update delphes cards
cp delphes_card.tcl ${proc}/Cards/delphes_card.dat

sed -i -e "s@_NEVENTS_@$nevts@g" run_${proc}.mg5
sed -i -e "s@_ISEED_@$seed@g" run_${proc}.mg5

cat run_${proc}.mg5

$MGDIR/bin/mg5_aMC run_${proc}.mg5
