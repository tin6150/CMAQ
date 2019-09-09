#!/bin/bash

## Hmm... Lucas' build instruction is for bash script, not csh

## compile Lucas Bastein Adjoin code
## largely follow instructions in CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/documentation/notes-on-building-the-code.txt

echo "starting setup_adjoin.sh"
date

echo '$HOME is set to: ' $HOME	# hmm... actually docker build , this is still /root.  not sure where got feeling it was / before...

cd CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB 

cd built_gcc_gfortran_serial_BENZ
source environment-user				## ie source environment-user in the "build" dir, not the higher level dir I used earlier.

make dir							## this isn't relative.  it is hard coded to use path in var DIR_REPO or something.
make pario

## not sure if there rest need to cd to a diff folder... 

make stenex
make jproc
make icon
make bcon
make cctm
make adjpost


echo $? | tee setup_adjoin.exitCode
echo "setup_adjoin.sh ends"
date
