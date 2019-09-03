#!/bin/sh
#
# RCS file, release, date & time of last delta, author, state, [and locker]
# $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/TOOLS/src/cast2ext/runCast2ext.sh,v 1.1.1.1 2005/09/09 19:17:32 sjr Exp $ 
#
# script for running the cast2ext program on Unix
#
#  converts CASTNET hourly data to a format used by sitecmp
#

BASE=/project/model_evalb/extract_util
 
EXECUTION_ID=cast2extV1.0; export EXECUTION_ID
 
EXEC=${BASE}/bin/${EXECUTION_ID}.exe


#   input file (downloaded from CASTNET web site) 
#   containing site-id, time-period, and data fields
INFILE=${BASE}/castnet/obs/castnet_hr.csv; export INFILE  


#  output file (csv text file can be used as input to sitecmp)
OUTFILE=${BASE}/castnet/output/cast2extV1.0.2001.csv; export OUTFILE

 ${EXEC}

echo run completed, output file = ${OUTFILE}

