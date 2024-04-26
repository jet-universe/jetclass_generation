#!/bin/bash

set -x

workdir=$(pwd)

echo $(hostname)
echo "workdir: $workdir"
echo "args: $@"
ls -l

proc=$1
outdir=$2
jobid=$3
nevts=$4
shower=$5

if [[ "$shower" == Pythia ]]; then
    seed=$jobid
    echo "Running with $shower parton shower!"
else
    echo "Shower option $shower is not recognized!"
    exit 1
fi

if [[ "$proc" == "HToBB" ]]; then
    seed=$((seed + 10000000))
elif [[ "$proc" == "HToCC" ]]; then
    seed=$((seed + 20000000))
elif [[ "$proc" == "HToGG" ]]; then
    seed=$((seed + 30000000))
elif [[ "$proc" == "HToWW4Q" ]]; then
    seed=$((seed + 40000000))
elif [[ "$proc" == "HToWW2Q1L" ]]; then
    seed=$((seed + 50000000))
fi

outdir=${outdir}/${shower}/${proc}

# run MadGraph event generation
./madgraph.sh ${proc} ${seed} ${nevts} ${shower}

if [[ -d ${proc}/Events/run_01_decayed_1 ]]; then
    inputdir=${proc}/Events/run_01_decayed_1
else
    inputdir=${proc}/Events/run_01
fi

source /cvmfs/sft.cern.ch/lcg/views/LCG_100/x86_64-centos7-gcc9-opt/setup.sh
DELPHESDIR=MYTOOLS/madgraph/LCG100/MG5_aMC_v3_1_1/Delphes
cd $DELPHESDIR
source DelphesEnv.sh
cd $workdir

# make jet trees
root -l -b -q "makeNtuples.C(\"$inputdir/*_delphes_events.root\",\"$inputdir/output_${proc}_${jobid}.root\")"
# root -l -b -q "makeNtuples.C(\"$inputdir/*_delphes_events.root\",\"$inputdir/output_genjet_${proc}_${jobid}.root\",\"GenFatJet\")"

# remove delphes output
rm -rf $inputdir/*_delphes_events.root
rm -rf $inputdir/*.hepmc
rm -rf $inputdir/*.dat
rm -rf $inputdir/*.log

rm -rf $outdir/run_$jobid
mkdir -p $outdir/run_$jobid
mv $inputdir/* $outdir/run_$jobid/

echo 'Done!'
