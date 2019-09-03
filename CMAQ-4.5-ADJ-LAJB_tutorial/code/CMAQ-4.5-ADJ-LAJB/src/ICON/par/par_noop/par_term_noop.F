
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

C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/ICON/src/par/par_noop/par_term_noop.F,v 1.1.1.1 2005/09/09 19:23:43 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

      SUBROUTINE PAR_TERM( CALLER, JDATE, JTIME, BEGTIME )
C.....................................................................
C
C  PURPOSE:    Performs no-operation for parallel termination. 
C
C
C  REVISION HISTORY: 
C       Original version 10/1998 by Al Bourgeois for parallel implementaion.
C
C
C  ARGUMENT LIST DESCRIPTION: 
C  IN:
C      CHARACTER*16    CALLER    ! Program name.
C      INTEGER         JDATE     ! Current model date, coded YYYYDDD.
C      INTEGER         JTIME     ! Current model time, coded HHMMSS.
C      REAL            BEGTIME   ! Wall-clock time (sec) at initialization.
C
C  OUT: none
C
C
C  LOCAL VARIABLE DESCRIPTION:  see below
C
C  CALLS: None 
C
C........................................................................

      IMPLICIT  NONE

C.......   INCLUDE FILES


C.......   ARGUMENTS:

      CHARACTER*16    CALLER     ! Program name.
      INTEGER         JDATE      ! Current model date, coded YYYYDDD.
      INTEGER         JTIME      ! Current model time, coded HHMMSS.
      REAL            BEGTIME    ! Wall-clock time (sec) at initialization.


C........................................................................
C     begin function PAR_TERM( CALLER, JDATE, JTIME, BEGTIME )

      RETURN
      END
