#!/bin/zsh

bin=../../other/psi/psi
testdir=../../testcode/psisrc

for i in $testdir/ct*psi; do
    echo $i
    time $bin $i
done
