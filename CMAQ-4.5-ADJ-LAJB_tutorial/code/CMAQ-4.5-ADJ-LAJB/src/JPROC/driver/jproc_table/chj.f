
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/JPROC/src/driver/jproc_table/chj.f,v 1.1.1.1 2005/09/09 19:22:14 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)chj.F	1.1 /project/mod3/JPROC/src/driver/jproc_table/SCCS/s.chj.F 23 May 1997 12:44:16

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      FUNCTION CHJ ( ZETA )
      
C**********************************************************************
C
C  Chapman function is used when the solar zenith angle exceeds
C     75 deg., this is the updated RADM2 version (VERSION 89137)
C     interpolates between values given in, e.g., McCartney (1976).
C
C  Edit history:
C
C     04/08/96 - Moved mods from Sasha's new code to this routine
C     01/03/95 - Function has been completely rewritten for  -SF-
C                readability and efficiency
C
C*********************************************************************

      IMPLICIT NONE

C.......ARGUMENTS and descriptions

      REAL          ZETA        ! zenith angle (deg)
      REAL          CHJ         ! chapman function

C.......LOCAL VARIABLES and descriptions
     
      INTEGER       I           ! angle loop index
      
      REAL          RM          ! zenith angle rounded up (deg)
      
      REAL          Y( 21 )     ! 
      DATA Y /   3.800,  4.055,  4.348,   4.687,   5.083, 
     &           5.551,  6.113,  6.799,   7.650,   8.732,
     &          10.144, 12.051, 14.730,  18.686,  24.905,
     &          35.466, 55.211, 96.753, 197.000, 485.000,
     &         1476.000/
      SAVE          Y

C*********************************************************************
C.......begin body of function CHJ

      I = MAX( INT( ZETA ) + 1, 75 )
      RM = FLOAT( I )

      CHJ = Y( I - 75 ) +
     &    ( Y( I - 74 ) - Y( I - 75 ) ) * ( ZETA - ( RM - 1.0 ) )

      RETURN
      END