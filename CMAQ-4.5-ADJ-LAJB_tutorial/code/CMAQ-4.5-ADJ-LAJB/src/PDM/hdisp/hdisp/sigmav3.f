
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
C $Header: /project/work/rep/PDM/src/hdisp/hdisp/sigmav3.F 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C*******************************************************************
      SUBROUTINE SIGMAV3( WSTAR, USTAR, HTMIX, L, SIGV, TL, ZC, FCOR )
C*******************************************************************
 
C  Version: 4/17/00
C  Input  : WSTAR,USTAR,HTMIX,L,ZC,F
C  Output : SIGV,TL
C  Purpose: calculate SIGV - standard deviation of turbulent component v'
C           calculate Lagrangian time scale TL
C  Method : For convective BL, let sigmav be 0.6W*
C           Nieustadt(1984) for stable BL
C           Arya(1984) for neutral BL

C  Called by YPARAM

      IMPLICIT NONE

      REAL WSTAR, USTAR, USTARL, HTMIX, L, SIGV, TL, ZC, FCOR

C---- UNSTABLE....
      IF ( L .LT. 0.0 .AND. L .GT. -50000.0 ) THEN
         SIGV = 0.6 * WSTAR
C----  STABLE....
      ELSE IF ( L .GT. .0 .AND. L .LT. 50000.0 )  THEN
         USTARL = USTAR * ( 1.0 - ZC / HTMIX ) ** 0.75
         SIGV = 1.6 * USTARL
C---- NEUTRAL....
      ELSE
         SIGV = 1.8 * EXP( -0.9 * ZC / HTMIX )
      ENDIF

C---- Set TL to 600 as recommended by Gryning et al. 1987
      TL = 600.0

      RETURN
      END