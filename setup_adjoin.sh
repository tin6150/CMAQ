#!/bin/bash

## Hmm... Lucas' build instruction is for bash script, not csh

## compile Lucas Bastein Adjoin code
## largely follow instructions in CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB/documentation/notes-on-building-the-code.txt

echo "starting setup_adjoin.sh"
export TZ="PST8PDT"
date

echo '$HOME is set to: ' $HOME	# hmm... actually docker build , this is still /root.  not sure where got feeling it was / before...

cd CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB 

AdjModel_list="built_gcc_gfortran_serial_BENZ built_gcc_gfortran_serial_SAPRC99ROS built_gcc_gfortran_parallel_SAPRC99ROS"

for AdjModel in $AdjModelList; do

	cd built_gcc_gfortran_serial_BENZ
	source environment-user				## ie source environment-user in the "build" dir, not the higher level dir I used earlier.

	make dir		2>&1 |  tee make.dir.log					## this isn't relative.  it is hard coded to use path in var DIR_REPO or something.
	make pario      2>&1 |  tee make.pario.log

	## not sure if there rest need to cd to a diff folder... 

	make stenex 	2>&1 | tee make.stenex.log
	make jproc 		2>&1 | tee make.jproc.log   
	## above had lot of errors like
	## wratt3.F90:(.text+0xe0b): undefined reference to `GOMP_critical_name_end'   11271e
	## GOMP = Gnu OpenMP implementation.  
	## disable -fopenmp in Makeinclude.  AND Makeinclude.Linux2_x86_64gfort seems to have solved the problme. a437304
	## (keep ParOpt="" in environment-user)

	make icon  		2>&1 | tee make.icon.log
	make bcon		2>&1 | tee make.bcon.log
	make cctm 		2>&1 | tee make.cctm.log
	make adjpost 	2>&1 | tee make.adjpost.log

	cd ../

done

echo $? | tee setup_adjoin.exitCode
echo "setup_adjoin.sh ends"
date
