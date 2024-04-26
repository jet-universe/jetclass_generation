#!/bin/bash

set -x

workdir=$(pwd)

echo "args: $@"

inputdir=$1

procs="HToBB  HToCC  HToGG  HToWW2Q1L  HToWW4Q  TTBar  TTBarLep  WToQQ  ZJetsToNuNu  ZToQQ"

for proc in $procs; do
    mkdir $inputdir/$proc/merged
    root -l -b -q "mergeTrees.C(\"$inputdir/$proc/run_*/output_$proc_*.root\",\"$inputdir/$proc/merged/$proc\")"
done

cd $inputdir
mkdir dataset && cd dataset
mkdir test_20M train_100M train_10M val_5M

cd train_10M
for proc in $procs; do
    ln -s ../../$proc/merged/$proc_00?.root ./
done
cd ..

cd train_100M
for proc in $procs; do
    ln -s ../../$proc/merged/$proc_0??.root ./
done
cd ..

cd val_5M
for proc in $procs; do
    ln -s ../../$proc/merged/$proc_12[0-4].root ./
done
cd ..

cd test_20M
for proc in $procs; do
    ln -s ../../$proc/merged/$proc_1[0-1][0-9].root ./
done
cd ..

cd $workdir

echo 'Done!'
