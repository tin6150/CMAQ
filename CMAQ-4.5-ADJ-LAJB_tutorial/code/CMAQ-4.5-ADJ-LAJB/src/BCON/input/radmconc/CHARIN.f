
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

*DK CHARIN

C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/BCON/src/input/radmconc/CHARIN.f,v 1.1.1.1 2005/09/09 19:25:17 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)CHARIN.f	2.1 /project/mod3/ICON/src/input/radmconc/SCCS/s.CHARIN.f 17 May 1997 08:33:48

      SUBROUTINE CHARIN(IUNIT,SARRAY,LENGTH,LFMT)
C*****
C**    DESCRIPTION: FORMATTED OR UNFORMATTED INPUT OF CHARACTER STRING
C**                 OF PASSED LENGTH
C**
C**
C**    Revision history:
C**    NO.   DATE     WHO      WHAT
C**    __    ____     ___      ____
C**    2    10/19/89  JKV   CONVERTED FOR USE ON IBM
C**    1      9/2/89  JNM     INCLUDE IN NF3
C**    0      11/88   JKV     BEGIN
C**
C**
C**    Input files:
C**
C**    Output files:
C**
C**    Called by: ROUTINES THAT MUST READ CHARACTER DATA
C**
C**    Calls the following subroutines:
C**
C23456789012345678901234567890123456789012345678901234567890123456789012
C
      CHARACTER*1 SARRAY(LENGTH)
      LOGICAL*1   LFMT
C
      IF (LFMT) THEN
c      write(*,*) ' reading sarray in CHARIN'
          READ(IUNIT,20,IOSTAT=IOST) SARRAY
c          write(*,*) ' read in sarray = ', SARRAY
20        FORMAT(80A1)
          IF (IOST.NE.0) THEN
             PRINT*,' CHARIN: FORMATTED ON:',IUNIT,' IOSTAT:',IOST
             STOP
          ENDIF
      ELSE
c      write(*,*) ' reading sarray unformatted in CHARIN'
          READ(IUNIT,IOSTAT=IOST) SARRAY
c          write(*,*) ' read in sarray = ', SARRAY
          IF (IOST.NE.0) THEN
             PRINT*,' CHARIN: UNFORMATTED ON:',IUNIT,' IOSTAT:',IOST
             STOP
          ENDIF
      ENDIF
      RETURN
C C C END OF SUBROUTINE CHARIN C C C C C C C C C C C C C C C C C C C C
      END
