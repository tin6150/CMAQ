
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/PDM/src/pldyn/pldyn/phai.f,v 1.1.1.1 2005/09/09 19:20:54 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C*************************************************************************
        SUBROUTINE PHAI( ANGL, XCO, YCO, XCN, YCN )
C*************************************************************************

C*** FUNCTION : Calculate the angle ANGL of plume trajectory,
C               THAT IS the line thru (XCO,YCO) and
C              (XCN,YCN), to the absolute model coord.

      IMPLICIT NONE

      REAL   ANGL, XCO, YCO, XCN, YCN, AUP, ALOW

      AUP = YCN - YCO
      ALOW = XCN - XCO

      IF ( ALOW .GT. 0.0 ) THEN         ! 1st & 2nd bounds
         ANGL = ATAN( AUP/ ALOW )
      ELSE IF ( ALOW .LT. 0.0 ) THEN    ! 3rd & 4th bounds
         ANGL = 4.0 * ATAN(1.0 ) + ATAN( AUP / ALOW )
      ELSE IF ( AUP .LT. 0.0 ) THEN     ! - Y axis
         ANGL = 6.0 * ATAN( 1.0 )
      ELSE                              ! + Y axis
         ANGL = 2.0 * ATAN( 1.0 )
      END IF

      RETURN
      END