
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/JPROC/src/driver/jproc_table/index2.f,v 1.1.1.1 2005/09/09 19:22:14 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)index2.F	1.1 /project/mod3/JPROC/src/driver/jproc_table/SCCS/s.index2.F 23 May 1997 12:44:17

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      INTEGER FUNCTION INDEX2 (NAME1, N, NAME2)     

C***********************************************************************
C
C  FUNCTION:
C
C    This routine searches for NAME1 in list NAME2    
C
C  REVISION HISTORY:
C
C    5/88   Modified for ROMNET
C
C  ARGUMENT LIST DESCRIPTION:
C
C    Input arguments:
C
C      NAME1       Character string being searched for
C      N           Length of array to be searched
C      NAME2       Character array to be searched
C
C    Output arguments:
C
C      INDEX1      The position within the NAME2 array that NAME1 
C                  found.  If string was not found, INDEX1 = 0
C
C  LOCAL VARIABLE DESCRIPTION:
C
C      None
C
C***********************************************************************

      IMPLICIT NONE

      INTEGER       N
      INTEGER       I

      CHARACTER*(*) NAME1
      CHARACTER*(*) NAME2(*)          

C...Assume NAME1 is not in list NAME2    

      INDEX2 = 0

      DO I = 1, N
        IF ( INDEX( NAME2( I ), NAME1 ) .EQ. 1 ) THEN
          INDEX2 = I
          RETURN     
        ENDIF
      END DO 

      RETURN
      END              
