#!/bin/sh
#
# RCS file, release, date & time of last delta, author, state, [and locker]
# $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/TOOLS/src/combine/combine.sh,v 1.1.1.1 2005/09/09 19:17:32 sjr Exp $ 
#
# what(1) key, module and SID; SCCS file; date and time of last delta:
# %W% %P% %G% %U%
#
#  example script for running the combine program on Unix
#
#  generates a new concentration file from output from the CMAQ model run
#

BASE=/project/model_evalb/extract_util

EXECUTION_ID=combineV3.0; export EXECUTION_ID

EXEC=${BASE}/bin/${EXECUTION_ID}.exe

## use GENSPEC switch to generate a new specdef file (does not generate output file)
   GENSPEC=N; export GENSPEC

## define name of species definition file
   SPECIES_DEF=spec_def.conc; export SPECIES_DEF

## define name of input files
   INFILE1=${BASE}/cmaq_data/CCTM_J2a.CONC.20010101; export INFILE1
   INFILE2=${BASE}/cmaq_data/METCRO3D_010101; export INFILE2
 
## define name of output file 
   OUTFILE=out.conc; export OUTFILE

${EXEC}

echo runs competed with output file = $OUTFILE
