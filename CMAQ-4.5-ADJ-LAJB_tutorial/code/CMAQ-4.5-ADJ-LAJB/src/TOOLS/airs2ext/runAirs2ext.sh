#!/bin/sh
#
# RCS file, release, date & time of last delta, author, state, [and locker]
# $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/TOOLS/src/airs2ext/runAirs2ext.sh,v 1.1.1.1 2005/09/09 19:17:32 sjr Exp $ 
#
# script for running the airs2ext program on Unix
#
#  program reads the output from rd_airs and writes hourly
#  or daily values in the sitecmp input format (csv)
#

BASE=/project/model_evalb/extract_util

EXECUTION_ID=airs2extV1.0; export EXECUTION_ID

EXEC=${BASE}/bin/${EXECUTION_ID}.exe

## assign input and output files
   INFILE=${BASE}/airs/output/rd_airsV1.0.ozone.2001.txt; export INFILE
   OUTFILE=${BASE}/airs/output/airs2extV1.0.ozone.2001.csv; export OUTFILE

## define species name for header
   SPECIES="ozone"; export SPECIES

## set time step (DAY or HOUR)
   STEP=DAY; export STEP
#  STEP=HOUR; export STEP

## set start and end dates (YYYYJJJ) format
   START_DATE=2001001; export START_DATE
   END_DATE=2001365; export END_DATE

## set domain window (comment out for all)
#  LAT_MIN=32.0; export LAT_MIN
#  LAT_MAX=47.0; export LAT_MAX
#  LON_MIN=-90.0; export LON_MIN
#  LON_MAX=-68.0; export LON_MAX


## run executable using sorted file
   ${EXEC}   

   echo program complete, output = ${OUTFILE}


