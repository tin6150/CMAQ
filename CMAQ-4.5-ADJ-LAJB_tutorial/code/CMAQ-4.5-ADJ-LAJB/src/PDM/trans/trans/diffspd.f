
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/PDM/src/trans/trans/diffspd.f,v 1.1.1.1 2005/09/09 19:20:54 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C**********************************************************
      SUBROUTINE DIFFSPD( U, V, DSPD, IHI, ILOW, KZ )
C**********************************************************
C
C**Calculate the difference of wind SPEEDs between plume      
C  top and bottom.
C 
      IMPLICIT NONE
      
      INTEGER IHI, ILOW, KZ, K, N, KE, KB, NUM, KK, ILOWX

      REAL U( KZ ), V( KZ ), SPD( 500 ), DDSPD( 500 )
      REAL DSPD, TEMP, SDIF, SDIF2

      N = 0
C  Do not use layer winds nearest sfc. if plume is surface-based in 
C  determining speed differences over plume in vertical.      
      IF ( ILOW. EQ. 1 ) THEN
         ILOWX = ILOW + 2
         IF ( ILOWX .GT. IHI ) ILOWX = IHI
      ELSE
         ILOWX = ILOW
      ENDIF
C  Patch for siuation where ILOWX = IHI.
      IF ( ILOWX .EQ. IHI ) IHI = ILOWX + 1

      DO K = ILOWX, IHI
          N = N + 1
          SPD( N ) = SQRT( V( K ) * V( K ) + U( K ) * U( K ) )
      END DO
      
      SDIF2 = SPD( N ) - SPD( 1 )
      
C******************Method *************************
C---- Use the biggest wind speed difference
C---- Calculate the difference of any 2 wind speeds
      KB = 2
!     KE = IHI - ILOW + 1
      KE = IHI - ILOWX + 1
      NUM = 0
      SDIF = 0.0
      
      DO K = KB , KE
         SDIF = SDIF + ABS( SPD( K-1 ) - SPD( K ) )
         DO KK = 1, K-1
            NUM = NUM + 1
            IF ( NUM .GT. 500 ) STOP  'STOP IN DIFFSPD: NUM > 500'
            DDSPD( NUM ) = ABS(SPD( KK ) - SPD( K ) )
         END DO
      END DO
C
C---- Choose the largest one..
      DO K = 1, NUM-1
         IF ( DDSPD( K ) .GT. DDSPD( K+1 ) ) THEN
            TEMP = DDSPD( K+1 )
            DDSPD( K+1 ) = DDSPD( K )
            DDSPD( K ) = TEMP
         END IF
      END DO

!     DSPD = DDSPD( NUM )
      SDIF = SDIF / FLOAT( NUM )
      DSPD = SDIF
      
!     write( *,* ) 'N,ILOWX,IHI,SDIF,SDIF2,dSPD,SPD', N, ILOWX, IHI,
!   &               SDIF, SDIF2, DSPD, ( SPD( K ), K = 1, N )
      RETURN
      END
