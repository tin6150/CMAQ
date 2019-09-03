
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/PDM/src/plrise/plrise/resbf1.f,v 1.1.1.1 2005/09/09 19:20:54 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C *********************************************************************
      SUBROUTINE RESBF1( DH, DHT, ZT, IQ, U, HS, USTAR, S, RBFLUX)
C**********************************************************************
 
C FUNCTION:  Calculate residual BOUYANCY at the height ZT above the stack.

C CALLED BY PLUMER

C        ARGUMENT LIST:
C INPUTS --
C        DH      R        HEIGHT OF PLUME RISE ABOVE STACK (M)
C        ZT      R        HEIGHT OF THE TOP OF THIS LAYER ABOVE
C                             STACK TOP (M)
C        IQ      I        PLUME RISE EQUATION USED ( 1-3 )
C        HSTAR   R        CONVECTIVE SCALING PARAMETER (M**2/S**3)
C        U       R        WIND SPEED (M/S)
C        HS      R        PHYSICAL STACK HEIGHT (M)
C        USTAR   R        FRICTION VELOCITY (M/S)
C        S       R        STABILITY PARAMETER (S**-2)
C        BFLUX   R        BUOYANCY FLUX at stack top  (M**4/S**3)

C OUTPUT --
C        RBFLUX  R        RESIDUAL BUOYANCY FLUX AT THE TOP OF THIS
C                             LAYER (M**4/S**3)

C ROUTINES CALLED --
C        NONE

      IMPLICIT NONE

      REAL DHT, DH, HS, R, RBFLUX, S, U, USTAR, ZT, H, C
      INTEGER IQ

      RBFLUX = 0.0
      R = DHT - ZT

      IF ( R .LT. 0.0 .OR. HS .LT. 0.0 ) GO TO 999

C---- According to IQ, which indicates which plume rise formulation was taken,
C     calc. residual buoyancy
C     Plume top (DHT which 1.5 DH) used in eqns to determine residual bouyancy.
C     Factor 1.5 used to compute C for unstable, 1.5 already built in to others.
      IF ( IQ .EQ. 1 ) THEN
         C = 1.5 * 30.0
         RBFLUX = U * ( ( DHT - ZT ) / C ) ** 1.6667
      ELSE IF ( IQ .EQ. 2 ) THEN
         H = HS + 0.6667 * DHT
         RBFLUX = ( R ** 1.6667 ) * U * USTAR * USTAR / ( 2.664 * H ** 0.6667 )
      ELSE IF ( IQ .EQ. 3 ) THEN
         RBFLUX = ( R ** 3.0 ) * U * S / 59.319
      END IF

C  Residual bouyancy flux is positive or zero.     
      RBFLUX = MAX( 0.0, RBFLUX )

999   CONTINUE

      RETURN
      END
