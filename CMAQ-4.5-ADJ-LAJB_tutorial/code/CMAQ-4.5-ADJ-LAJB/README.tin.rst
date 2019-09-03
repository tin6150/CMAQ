

This directory contain "one of" the Adjoin model by Lucas A. J. Bastien

source
======

# copy the main source files:

cd /global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB  
cp -pr LICENSE makefile environment-user_example src documentation environment /global/scratch/tin/tin-gh/CMAQ/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB


## being lazy, reuse already defined, tried and tested config settings (environment-user) files

SRC_DIR=/global/home/groups-sw/pc_adjoint/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB
DST_DIR=/global/scratch/tin/tin-gh/CMAQ/CMAQ-4.5-ADJ-LAJB_tutorial/code/CMAQ-4.5-ADJ-LAJB     # my git repo location
cd $DST_DIR

BUILD_LIST="built_gcc_gfortran_parallel_O3 built_gcc_gfortran_parallel_O3_default-eddy built_gcc_gfortran_parallel_O3_modified-eddy built_gcc_gfortran_parallel_SAPRC99ROS built_gcc_gfortran_serial_BENZ built_gcc_gfortran_serial_O3 built_gcc_gfortran_serial_SAPRC99ROS"


# crate a build dir for each adjoin target
# and copy the already defined environment-user file for that model

for ITEM in $BUILD_LIST; do
	mkdir $ITEM
done

for ITEM in $BUILD_LIST; do
	cp -p ${SRC_DIR}/${ITEM}/environment-user ${ITEM}
	cp -p ${SRC_DIR}/${ITEM}/makefile         ${ITEM}
done

# expect build process to create the bin bld and lib folders inside each of the "target"



Compiling
=========

tba
