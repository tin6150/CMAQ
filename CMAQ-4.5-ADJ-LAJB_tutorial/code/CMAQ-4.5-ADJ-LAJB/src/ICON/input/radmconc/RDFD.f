
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

C########

C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/ICON/src/input/radmconc/RDFD.f,v 1.1.1.1 2005/09/09 19:23:43 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)RDFD.f	2.1 /project/mod3/ICON/src/input/radmconc/SCCS/s.RDFD.f 17 May 1997 08:33:54

*DK RDFD
      SUBROUTINE RDFD(IUNIT,STRIN,LFMT)
C********
C**    DESCRIPTION: READ THE FILE DESCRIPTOR RECORD
C**
C**
C**
C**
C**
C**    Revision history:
C**    NO.   DATE     WHO      WHAT
C**    __    ____     ___      ____
C**    2    10/19/89  JKV     CONVERTED FOR USE ON IBM
C**    1     9/2/89   JNM     INCLUDE IN NF3
C**    0     11/89    JKV     BEGIN
C**
C**
C**    Input files:
C**
C**    Output files:
C**
C**    Called by: ROUTINES THAT READ FILE DESCRIPTOR RECORDS
C**
C**    Calls the following subroutines: CHARIN1, CHAROUT1
C**
C
      INCLUDE 'hw_r2fd.icl'
c     INCLUDE 'logdb.cdk'
      CHARACTER*80 STRIN
      LOGICAL*1    LFMT
C
C
C     READ BUFFER
      CALL CHARIN(IUNIT,R2FDSTR,80,LFMT)
C     REPORT OUT THE DATA VALUES TO THE LOG FOR THE DATA BASE
      CALL CHAROUT(LOGDB,R2FDSTR,80,DBFMT)
C
C     REPORT VALUES FOR THE NL2 FILE DESCRIPTOR RECORD VARIABLES.
      PRINT *,' NL2 FILE DESCRIPTOR VARIABLES FROM RDFD:'
      PRINT *,' R2FD START DATE: ',R2FDSD
      PRINT *,' R2FD START TIME: ',R2FDST
      PRINT *,' R2FD STEPSIZE SECONDS: ',R2FDSS
      PRINT *,' R2FD GRID ID: ', R2FDGID
      PRINT *,' R2FD TEST FLAG: ',R2FDTST
      PRINT *,' R2FD NUMBER OF DIMENSIONS: ',R2FDNUM
      DO 105,I = 1, 4  ! only four dimensions are in use jkv
      PRINT *,' R2FD DIMENSION GROUP',I,': ',R2FDDMG(I)
105   CONTINUE
C
C     SET DATA VALUES RETURNED EQUAL TO VALUES READ IN BY RDFD
      STRIN = R2FDSTR
C
C     RETURN TO CALLING PROGRAM.
      RETURN
C C C END OF SUBROUTINE RDFD  C C C C C C C C C C C C C C C C C C C C C
      END
