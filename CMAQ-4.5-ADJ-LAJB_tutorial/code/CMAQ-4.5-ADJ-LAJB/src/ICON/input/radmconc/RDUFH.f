
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

C

C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/ICON/src/input/radmconc/RDUFH.f,v 1.1.1.1 2005/09/09 19:23:43 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)RDUFH.f	2.1 /project/mod3/ICON/src/input/radmconc/SCCS/s.RDUFH.f 17 May 1997 08:33:59

*DK RDUFH
      SUBROUTINE RDUFH(IUNIT,STRIN,LFMT)
C********
C**    DESCRIPTION: READ THE UNIVERSAL FILE HEADER
C**
C**
C**
C**
C**
C**    Revision history:
C**    NO.   DATE     WHO      WHAT
C**    __    ____     ___      ____
C**    2    10/19/89  JKV      CONVERTED FOR USE ON IBM
C**    1    9/2/89    JNM     INCLUDE IN NF3
C**    0    11/88     JKV     BEGIN
C**
C**
C**    Input files:
C**
C**    Output files:
C**
C**    Called by: ROUTINES THAT READ THE UNIVERSAL FILE HEADER
C**
C**    Calls the following subroutines: CHARIN, CHAROUT
C**
C
      INCLUDE 'hw_ufhead.icl'
      INCLUDE 'hw_logdb.icl'
      CHARACTER*80 STRIN,LABEL
      LOGICAL*1    LFMT
      DATA LABEL/'#FILE IN    '/
C
C     READ BUFFER
      CALL CHARIN(IUNIT,UFHSTR,80,LFMT)
C     REPORT OUT THE DATA VALUES TO LOG FOR DATA BASE MGMT SYSTEM
      CALL CHAROUT(LOGDB,LABEL,80,DBFMT)
      CALL CHAROUT(LOGDB,UFHSTR,80,DBFMT)
C
C     REPORT OUT THE VALUES FOR THE UNIVERSAL FILE HEADER VARIABLES.
      PRINT *,' UNIVERSAL FILE HEADER VALUES FROM RDUFH: '
      PRINT *,' UFH DATA SET NAME:    ',UFHDSN
      PRINT *,' UFH DATE CREATED:     ',UFHDC
      PRINT *,' UFH TIME CREATED:     ',UFHTC
      PRINT *,' UFH SYSTEM ORIGIN:    ',UFHSO
      PRINT *,' UFH PROCESSOR ORIGIN: ',UFHPO
      PRINT *,' UFH FILE TYPE:        ',UFHFT
C
C     SET DATA VALUES RETURNED EQUAL TO THOSE READ IN BY UFHIN.
      STRIN = UFHSTR
C
C     RETURN TO CALLING PROGRAM.
      RETURN
C C C END OF SUBROUTINE RDUFH C C C C C C C C C C C C C C C C C C C C C
      END
