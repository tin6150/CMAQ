#!/bin/bash

## Hmm... Lucas' build instruction is for bash script, not csh

## compile Lucas Bastein Adjoin code
## largely follow instructions in CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/documentation/notes-on-building-the-code.txt

echo "starting setup_adjoin.sh"
date

echo '$HOME is set to: ' $HOME	# expect / in container build script

cd CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB 
source environment-user

make dir
make pario
make stenex
make jproc
make icon
make bcon
make cctm
make adjpost


echo $? | tee setup_adjoin.exitCode
echo "setup_adjoin.sh ends"
date
