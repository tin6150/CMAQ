
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/JPROC/src/driver/jproc_table/readprof.f,v 1.1.1.1 2005/09/09 19:22:14 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)readprof.F	1.2 /project/mod3/JPROC/src/driver/jproc_table/SCCS/s.readprof.F 04 Jul 1997 09:40:28

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      SUBROUTINE READPROF ( XAIR, AIR, XO3, XDOBS, O3, AER, XT, T )
         
C*********************************************************************
C
C  the subroutine readprof reads the atmospheric profiles file.
C    The input data are:
C
C     XO3 (nsea,nlat,nlev) - ozone profiles
C     XT  (nsea,nlat,nlev) - temperature profiles
C     XAIR(nsea,nlat,nlev) - air concentration profile
C     XDOBS(nlat,MONTH)    - average dobson values
C
C*********************************************************************

      IMPLICIT NONE
      
      INCLUDE 'JVALPARMS.EXT'    ! jproc parameters

C...........PARAMETERS and their descriptions
      
      INTEGER      XSTAT1             ! I/O ERROR exit status
      PARAMETER  ( XSTAT1 = 1 )

C...........ARGUMENTS and their descriptions
      
      REAL         O3 ( MXLEV )        ! ozone profile
      REAL         AER( MXLEV )        ! aerosol attenuation profile
      REAL         T  ( MXLEV )        ! interpolated temp profile
      REAL         AIR( MXLEV )        ! interpolated air profile
      REAL         XDOBS( 19, 12 )     ! lat-season ozone values
      REAL         XO3 ( 12, 19, MXLEV ) ! season-lat-vert ozone profile
      REAL         XT  ( 12, 19, MXLEV ) ! season-lat-vert temp profile
      REAL         XAIR( 12, 19, MXLEV ) ! air concentration

C...........LOCAL VARIABLES and their descriptions:

      CHARACTER*16 PNAME               ! program name
      DATA         PNAME   / 'READPROF' /
      CHARACTER*16 PFFILE              ! profiles i/o logical name
      DATA         PFFILE   / 'PROFILES' /
      CHARACTER*255 EQNAME              ! full name of profile file
      CHARACTER*80 MSG                 ! message
      DATA         MSG / '    ' /

      INTEGER      IMON                ! month index
      INTEGER      ILAT                ! latitude index
      INTEGER      ILEV                ! level index
      INTEGER      ISEA                ! season index
      INTEGER      IOST                ! io status
      INTEGER      PFUNIT              ! profiles io unit

C...........EXTERNAL FUNCTIONS and their descriptions:

      INTEGER      JUNIT               ! used to get next IO unit #

C*********************************************************************
C     begin body of subroutine READPROF

C...read 4 seasons of 19xMXLEV fields of O3, T and M (air pressure in
C...  molecules/cm**3).  T and M data is from Louis (Ph.D. thesis 1974
C...  U.of Colorado).  O3 profiles are from Isaksen et al.
C...  diabatic 2D model

      CALL NAMEVAL ( PFFILE, EQNAME )
      PFUNIT = JUNIT( )

      OPEN( UNIT = PFUNIT,
     &      FILE = EQNAME,
     &      STATUS = 'OLD',
     &      IOSTAT = IOST )

C...check for open errors

      IF ( IOST .NE. 0) THEN
        MSG = 'Could not open the PROFILES data file'
        CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT1 )
      END IF

      WRITE( 6, 2001 ) PFUNIT, EQNAME

      DO 70 ISEA = 1, 4

C...read ozone profiles

        DO ILAT = 1, 19
          READ( PFUNIT, 1001, IOSTAT = IOST )
     &        ( XO3 ( ISEA, ILAT, ILEV ), ILEV = 1, MXLEV )

C...check for read errors

          IF ( IOST .GT. 0) THEN
            MSG = 'Errors occurred while reading XO3 in PROFILES file'
            CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT1 )
          END IF

        END DO

C...read temperature profiles

        DO ILAT = 1, 19
          READ( PFUNIT, 1001, IOSTAT = IOST )
     &        ( XT  ( ISEA, ILAT, ILEV ), ILEV = 1, MXLEV )

C...check for read errors

          IF ( IOST .GT. 0) THEN
            MSG = 'Errors occurred while reading XT in PROFILES file'
            CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT1 )
          END IF
        END DO

C...read pressure/air concentration profiles

        DO ILAT = 1, 19
          READ( PFUNIT, 1001, IOSTAT = IOST )
     &        ( XAIR( ISEA, ILAT, ILEV ), ILEV = 1, MXLEV )

C...check for read errors

          IF ( IOST .GT. 0) THEN
            MSG = 'Errors occurred while reading XAIR in PROFILES file'
            CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT1 )
          END IF

        END DO
70    CONTINUE
C
C...Read dobson values (12 months, 19 latitudes):
C... Source = WMO(1981) originally from Deutch 1971.
C... These values are used if subroutine O3SCAL is invoked in main progr
C
      DO IMON = 1, 12
        READ( PFUNIT, *, IOSTAT = IOST ) ( XDOBS( ILAT, IMON ),
     &                                            ILAT = 1, 19 )

C...check for read errors

        IF ( IOST .GT. 0) THEN
          MSG = 'Errors occurred while reading XDOBS in PROFILES file'
          CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT1 )
        END IF

      END DO
C
C...read standard profiles: air, temp, and ozone are from
C...  Nicolet et al. 1982 Planet.Space Sci. v30 p935.  Aerosols from
C...  Elterman 1968 AFCRL-68-0153 report (Air Force Cambridge Labs.)
C...  These standard profiles will be used if subroutine INTERP(DLAT,I
C...  is not invoked.  If it is invoked (in the main program), local
C...  profiles will be interpolated to latitude and date, then used.
C...  In either case, aerosol profiles are currently from here.
C
      DO ILEV = 1, MXLEV
        READ( PFUNIT, *, IOSTAT = IOST ) T ( ILEV ), AIR( ILEV ),
     &                                   O3( ILEV ), AER( ILEV )

C...check for read errors

        IF ( IOST .GT. 0) THEN
          MSG ='Errors occurred while reading STD PROF in PROFILES file'
          CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT1 )
        END IF

      END DO

      CLOSE( PFUNIT )

C...formats

1001  FORMAT( 8E10.3 )
2001  FORMAT( 1X, '...Opening File on UNIT ', I2, /, 1X, A255, / )

      RETURN
      END