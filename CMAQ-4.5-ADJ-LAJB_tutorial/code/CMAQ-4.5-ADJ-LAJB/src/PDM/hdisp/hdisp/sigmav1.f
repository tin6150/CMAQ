
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/PDM/src/hdisp/hdisp/sigmav1.f,v 1.1.1.1 2005/09/09 19:20:54 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C*****************************************************************
        SUBROUTINE SIGMAV1( USTAR, HTMIX, L, SIGV, TL, ZC, FCOR )
C*****************************************************************

C  Version: 5/25/95 by ywu
C  Input  : USTAR,HTMIX,L,ZC,FCOR
C  Output : SIGV,TL
C  FUNCTION: calculate SIGV - standard deviation of turbulent component v'
C            calculate Lagrangian time scale TL
C  Method : from Hanna et al.(1982) Handbook

C  Called by YPARAM
      IMPLICIT NONE

      REAL   USTAR, HTMIX, L, SIGV, TL, ZC, FCOR

C---- UNSTABLE....
      IF ( L .LT. 0.0 .AND. L .GT. -50000.0 ) THEN
         SIGV = USTAR * ( 12.0 - 0.5 * HTMIX / L ) ** 0.33
         TL = 0.15 * HTMIX / SIGV
C---- STABLE....
      ELSE IF ( L .GT. 0.0 .AND. L .LT. 50000.0 )  THEN
         SIGV = 1.3 * USTAR * ( 1.0 - ZC / HTMIX )
         TL = 0.07 * ( HTMIX * ZC ) ** 0.5 / SIGV
C---- NEUTRAL....
      ELSE    
         SIGV = 1.3 * USTAR * EXP( -2.0 * FCOR*ZC / USTAR )
         TL = 0.5 * ( ZC / SIGV ) / ( 1.0 + 15.0 * FCOR * ZC / USTAR )
      END IF

      RETURN
      END
