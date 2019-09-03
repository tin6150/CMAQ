#!/bin/sh
#
# RCS file, release, date & time of last delta, author, state, [and locker]
# $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/TOOLS/src/rd_airs/runRd_airs.sh,v 1.1.1.1 2005/09/09 19:17:32 sjr Exp $ 
#
# what(1) key, module and SID; SCCS file; date and time of last delta:
# %W% %P% %G% %U%
#
# script for running the rd_airs program on Unix
#
#  program reads the raw AIRS data and writes hourly values in one day per record format
#

BASE=/project/model_evalb/extract_util

EXECUTION_ID=rd_airsV1.0; export EXECUTION_ID

EXEC=${BASE}/bin/${EXECUTION_ID}.exe


   INFILE=${BASE}/airs/obs/airs_2001.txt; export INFILE
   SITEFILE=${BASE}/airs/obs/airs_sites.AA; export SITEFILE
   OUTFILE=${BASE}/airs/output/rd_airsV1.0.ozone.2001.txt; export OUTFILE

# Uncomment if you want a subset of states
#  STATES="NC,SC,TN"; export STATES

# Uncomment if you want a subset of years 
   YEARS="2001"; export YEARS

# Parameter code
#   OZONE = 44201 (default)
#   SO2   = 42401
#   CO    = 42101

   PARAMETER="44201"; export PARAMETER

# set CHECKUNITS switch
   CHECKUNITS=Y; export CHECKUNITS

#  input file must be sorted
   echo Sorting input file ${INFILE}
   SORTED=sorted.$$
   sort ${INFILE} > ${SORTED}
   INFILE=${SORTED}

#  run executable using sorted file
   ${EXEC}   

#  remove sorted file
   rm ${SORTED} 

   echo program complete, output = ${OUTFILE}


