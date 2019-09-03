
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

*DK RDTEXT

C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/ICON/src/input/radmconc/RDTEXT.f,v 1.1.1.1 2005/09/09 19:23:43 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)RDTEXT.f	2.1 /project/mod3/ICON/src/input/radmconc/SCCS/s.RDTEXT.f 17 May 1997 08:33:57

      SUBROUTINE RDTEXT(IUNIT,TEXT,LFMT)
C********
C**    DESCRIPTION:READ THE ELM TEXT GROUP FROM A FILE AND REPORT
C**                IN LOG(S)
C**
C**
C**
C**    Revision history:
C**    NO.   DATE     WHO      WHAT
C**    __    ____     ___      ____
C**    2    10/19/89  JKV      CONVERTED FOR USE ON IBM
C**    1     8/29/89  JNM     INCLUDE IN NF3
C**    0     11/89    JKV     BEGIN
C**
C**
C**    Input files:
C**
C**    Output files:
C**
C**    Called by: ROUTINES THAT READ TEXT RECORDS
C**
C**    Calls the following subroutines: CHARIN1, CHAROUT1
C**
C
      INCLUDE 'hw_logdb.icl'
C
      CHARACTER*80 TEXT(20)
      LOGICAL*1    LFMT
C
C     TEXT    THE FILE SPECIFIC ARRAY OF TEXT RECORDS PASSED BY THE
C             CALLING ROUTINE.
C     LFMT    THE LOGICAL FOR FILE FORMAT
C
C
C     REPORT OUT THE TEXT STRINGS WHILE READING.
C
      PRINT *,' NL2 TEXT RECORDS FROM RDTEXT: '
C
      DO 200, I = 1, 20
C
C     READ BUFFER
      CALL CHARIN(IUNIT,TEXT(I),80,LFMT)
C     REPORT NL2 TEXT TO DATA BASE LOG.
      CALL CHAROUT(LOGDB,TEXT(I),80,DBFMT)
C
      PRINT*,I,TEXT(I)
C
200   CONTINUE
C
C     RETURN TO CALLING PROGRAM.
201   RETURN
C C C END OF SUBROUTINE RDTEXT  C C C C C C C C C C C C C C C C C C C C
      END
