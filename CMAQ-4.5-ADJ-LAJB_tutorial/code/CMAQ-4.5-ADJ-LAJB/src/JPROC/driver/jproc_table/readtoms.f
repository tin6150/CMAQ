
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/JPROC/src/driver/jproc_table/readtoms.f,v 1.1.1.1 2005/09/09 19:22:14 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)readtoms.F	1.2 /project/mod3/JPROC/src/driver/jproc_table/SCCS/s.readtoms.F 04 Jul 1997 09:40:36

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      SUBROUTINE READTOMS ( JDT, DOBNEW )

C*********************************************************************
C
C  This routine reads the daily gridded data for real-time NIMBUS-7/
C     TOMS data for January 31,1991.  variables lat and lon contain
C     the latitudes and longitudes of the center of each of the grid
C     cells in the array ozone.                                    
C
C  HISTORY:
C     04/11/96  S.Roselle  Modified program to conform with Models3
C                          coding standards and to average latitudinal
C                          bands of TOMS values
C     04/10/96  Program received from NASA via web/ftp
C
C*********************************************************************

      IMPLICIT NONE

C...........PARAMETERS and their descriptions

      INTEGER      JVLAT              ! number of output latitudes
      PARAMETER  ( JVLAT = 6 )

      INTEGER      NLAT               ! number of input latitudes
      PARAMETER  ( NLAT = 180 )

      INTEGER      NLON               ! number of input longitudes
      PARAMETER  ( NLON = 288 )

      INTEGER      XSTAT1             ! I/O ERROR exit status
      PARAMETER  ( XSTAT1 = 1 )

C...........ARGUMENTS and their descriptions

      INTEGER      JDT                ! julian date (yyyyddd)

      REAL         DOBNEW( JVLAT )

C...........LOCAL VARIABLES and their descriptions:

      CHARACTER*16 TMFILE             ! TOMS i/o logical name
      DATA         TMFILE   / 'TOMS' /
      CHARACTER*16 PNAME
      DATA         PNAME   / 'READTOMS' /
      CHARACTER*255 EQNAME             ! full name of TOMS file
      CHARACTER*80 HEADER
      CHARACTER*80 MSG
      DATA         MSG / '    ' /

      INTEGER      ILAT               ! latitude index
      INTEGER      JLAT               ! latitude index
      INTEGER      ILON               ! longitude index
      INTEGER      DDD                ! julian day
      INTEGER      YYYY               ! year
      INTEGER      TJDATE             ! julian date for toms data
      INTEGER      IOST               ! io status
      INTEGER      TMUNIT             ! unit number for TOMS file
      INTEGER      OZONE(NLON,NLAT)
      INTEGER      COUNT( JVLAT )

      REAL         DLAT
      REAL         DLON
      REAL         LAT( NLAT )
      REAL         LON( NLON )
      REAL         XLATJV( JVLAT )    ! latitudes for photolytic rates
      DATA         XLATJV / 10.0, 20.0, 30.0, 40.0, 50.0, 60.0 /

C...........FUNCTIONS and their descriptions:

      INTEGER      JUNIT              ! used to get the I/O unit number

C*********************************************************************
C     begin body of program READTOMS
                                                              
C...calculate latitudes and longitudes                   

      DLAT = 1.0
      DO ILAT = 1, NLAT
        LAT( ILAT ) = -89.5 + ( ILAT - 1 ) * DLAT
      END DO

      DLON = 1.25
      DO ILON = 1, NLON
        LON( ILON ) = -179.375 + ( ILON - 1 ) * DLON
      END DO

C...open the input file

      TMUNIT = JUNIT( )
      CALL NAMEVAL ( TMFILE, EQNAME )

      OPEN ( UNIT = TMUNIT,
     &       FILE = EQNAME,
     &       FORM = 'FORMATTED',
     &       STATUS = 'OLD',
     &       IOSTAT = IOST )

C...check for open errors

      IF ( IOST .NE. 0) THEN
        MSG = 'Could not open the TOMS data file'
        CALL M3EXIT( PNAME, JDT, 0, MSG, XSTAT1 )
      END IF

      WRITE( 6, 2001 ) TMUNIT, EQNAME

C...read in the header lines

      READ( TMUNIT, 1001 ) DDD, YYYY
      TJDATE = YYYY * 1000 + DDD

C...check to see if julian date of file matches julian date requested
C...  and warn user if they do not match

      IF ( TJDATE .NE. JDT ) THEN
        MSG = 'Julian date of TOMS file does not match requested date '
        CALL M3WARN( PNAME, JDT, 0, MSG )
      END IF
      
C...read in the other header lines

      READ( TMUNIT, 1003 ) HEADER
      READ( TMUNIT, 1003 ) HEADER

C...read in the data into the array ozone

      DO ILAT = 1, NLAT
        READ( TMUNIT, 1005, IOSTAT = IOST ) ( OZONE( ILON, ILAT ),
     &                                               ILON = 1, NLON )

        IF ( IOST .NE. 0) THEN
          MSG = 'Errors occurred while reading TOMS file'
          CALL M3EXIT( PNAME, JDT, 0, MSG, XSTAT1 )
        END IF

      END DO

C...close the input file

      CLOSE( TMUNIT )

C...process/print the ozone data

      DO JLAT = 1, JVLAT

        COUNT ( JLAT ) = 0
        DOBNEW( JLAT ) = 0.0

        DO ILAT = 1, NLAT

          IF ( ( LAT( ILAT ) .GT. ( XLATJV( JLAT) - 5.0 ) ) .AND.
     &         ( LAT( ILAT ) .LT. ( XLATJV( JLAT) + 5.0 ) ) ) THEN

            DO ILON = 1, NLON
              IF ( ( LON( ILON ) .GT. -105.0 ) .AND.
     &             ( LON( ILON ) .LT.  -75.0 ) ) THEN
                  COUNT ( JLAT ) = COUNT( JLAT ) + 1
                  DOBNEW( JLAT ) = DOBNEW( JLAT )
     &                           + FLOAT( OZONE ( ILON, ILAT ) )
              END IF
            END DO

          END IF

        END DO

        DOBNEW( JLAT ) = DOBNEW( JLAT ) / FLOAT( COUNT( JLAT ) )
        PRINT *, DOBNEW( JLAT ), COUNT( JLAT )
      END DO

C...format statements

1001  FORMAT( 6X, I3, 9X, I4 )
1003  FORMAT( A80 )
1005  FORMAT( 1X, 25I3 )
2001  FORMAT( 1X, '...Opening File on UNIT ', I2, /, 1X, A255 )

      RETURN
      END
