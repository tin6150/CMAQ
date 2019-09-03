
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

*DK RDSPR

C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/ICON/src/input/radmconc/RDSPR.f,v 1.1.1.1 2005/09/09 19:23:43 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)RDSPR.f	2.1 /project/mod3/ICON/src/input/radmconc/SCCS/s.RDSPR.f 17 May 1997 08:33:56

      SUBROUTINE RDSPR(IUNIT,SNAME,LNAME,UNIT,MAPI,LFMT)
C********
C**    DESCRIPTION: READ AN ELM SPECIES RECORD
C**
C**
C**
C**
C**
C**    Revision history:
C**    NO.   DATE     WHO      WHAT
C**    __    ____     ___      ____
C**    2    10/19/89  JKV      CONVERTED FOR USE ON IBM
C**    1     9/2/89   JNM      ADAPTED FOR ELM
C**    0     11/88    JKV      BEGIN
C**
C**
C**    Input files:
C**
C**    Output files:
C**
C**    Called by: ROUTINES THAT READ SPECIES GROUP RECORDS
C**
C**    Calls the following subroutines: CHARIN1, CHAROUT1
C**
C
      CHARACTER*5 SNAME
      CHARACTER*20 LNAME
      CHARACTER*10 UNIT
      CHARACTER*4 MAPI
C      SNAME,  SPECIES SHORT NAME ARGUMENT
C      LNAME,  SPECIES LONG NAME ARGUMENT
C      UNIT,   SPECIES UNITS ARGUMENT
C      MAPI, MAPPING INFORMATION ARGUMENT
      LOGICAL*1    LFMT
C
      INCLUDE 'hw_r2sp.icl'
      INCLUDE 'hw_logdb.icl'
C
C
C     READ BUFFER
      CALL CHARIN(IUNIT,SPREC,80,LFMT)
C     REPORT OUT THE DATA VALUES TO LOG FOR DATA BASE.
      CALL CHAROUT(LOGDB,SPREC,80,DBFMT)
C
C     REPORT VALUES FOR THE NL2 SPECIES RECORD.
      PRINT *,' NL2 SPECIES RECORD VALUES FROM RDSPR: ',
     &' SHORT NAME: ',SSNAME,' LONG NAME: ',SLNAME,' UNITS: ',SUNIT,
     &' MAPINFO: ',MAPINFO
C
C     SET RETURN VALUES EQUAL TO THOSE READ IN BY RDSPR.
       SNAME = SSNAME
       LNAME = SLNAME
       UNIT = SUNIT
       MAPI = MAPINFO
C
C     RETURN TO CALLING PROGRAM.
      RETURN
C C C END OF SUBROUTINE RDSPR C C C C C C C C C C C C C C C C C C C C C
      END
