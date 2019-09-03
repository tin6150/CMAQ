
C***********************************************************************
C   Portions of Models-3/CMAQ software were developed or based on      *
C   information from various groups: Federal Government employees,     *
C   contractors working on a United States Government contract, and    *
C   non-Federal sources (including research institutions).  These      *
C   research institutions have given the Government permission to      *
C   use, prepare derivative works, and distribute copies of their      *
C   work in Models-3/CMAQ to the public and to permit others to do     *
C   so.  EPA therefore grants similar permissions for use of the       *
C   Models-3/CMAQ software, but users are requested to provide copies  *
C   of derivative works to the Government without restrictions as to   *
C   use by others.  Users are responsible for acquiring their own      *
C   copies of commercial software associated with Models-3/CMAQ and    *
C   for complying with vendor requirements.  Software copyrights by    *
C   the MCNC Environmental Modeling Center are used with their         *
C   permissions subject to the above restrictions.                     *
C***********************************************************************

C######################################################################

C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/BCON/src/input/radmconc/hw_filfmt.icl,v 1.1.1.1 2005/09/09 19:25:17 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)hw_filfmt.icl	2.1 /project/mod3/ICON/src/input/radmconc/SCCS/s.hw_filfmt.icl 17 May 1997 08:34:02

C## filename:       hr_filfmt.icl
C## model version:  HR-RADM (Soon to be RADM 2.7)
C## date:           October 5, 1991
C## developer:      AREAL, EPA, CSC, & DynTel
C######################################################################
*CDK FILFMT
C     FILE SPECIFIC LOGICALS INDICATING WHETHER FILE IS FORMATTED OR UN.
      LOGICAL     I1FMT,I2FMT,EEFMT,M1FMT,M2FMT,
     &              C1FMT,C2FMT,C3FMT,N1FMT,N2FMT,UIFMT,BCFMT,JVFMT
      COMMON/FILFMT/I1FMT,I2FMT,EEFMT,M1FMT,M2FMT,
     &              C1FMT,C2FMT,C3FMT,N1FMT,N2FMT,UIFMT,BCFMT,JVFMT
cbl ======= for read and write ascii data  
C      COMMON/FILFMT/TRFMT,FAFMT      
C      LOGICAL     TRFMT,FAFMT
C######################################################################
C######################################################################
