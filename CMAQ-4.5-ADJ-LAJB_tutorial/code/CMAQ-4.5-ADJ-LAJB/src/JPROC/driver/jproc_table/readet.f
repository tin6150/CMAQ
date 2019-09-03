
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/JPROC/src/driver/jproc_table/readet.f,v 1.1.1.1 2005/09/09 19:22:14 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)readet.F	1.2 /project/mod3/JPROC/src/driver/jproc_table/SCCS/s.readet.F 04 Jul 1997 09:39:52

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      SUBROUTINE READET ( NWL, STWL, MIDWL, ENDWL, F )
         
C*********************************************************************
C
C  the subroutine readet reads the extra terrestrial radiation file.
C    The input data are:
C
C     NWL                   - number of wavelength bands
C     STWL(mxwl)            - array of nominal starting wavelengths of
C                             spectral interval
C     MIDWL(mxwl)           - array of nominal center wavelengths of
C                             spectral interval
C     ENDWL(mxwl)           - array of nominal ending wavelengths of
C                             spectral interval
C     F(mxwl)               - extraterrestrial solar irradiance
C
C*********************************************************************

      IMPLICIT NONE

      INCLUDE 'JVALPARMS.EXT'          ! jproc parameters

C...........PARAMETERS and their descriptions
      
      INTEGER      XSTAT1             ! I/O ERROR exit status
      PARAMETER  ( XSTAT1 = 1 )

      INTEGER      XSTAT2             ! Program ERROR exit status
      PARAMETER  ( XSTAT2 = 2 )

C...........ARGUMENTS and their descriptions
      
      REAL         ENDWL( MXWL )       ! wavelength band upper limit
      REAL         F    ( MXWL )       ! extra-terrestrial radiation
      REAL         MIDWL( MXWL )       ! wavelength midpoints
      REAL         STWL ( MXWL )       ! wavelength band lower limit

C...........LOCAL VARIABLES and their descriptions:

      CHARACTER*1  TYPE                ! cs/qy spectra type
      CHARACTER*16 ETFILE              ! ET i/o logical name
      DATA         ETFILE   / 'ET' /
      CHARACTER*16 PNAME               ! program name
      DATA         PNAME   / 'READET' /
      CHARACTER*255 EQNAME              ! full name of ET file
      CHARACTER*80 MSG                 ! message
      DATA         MSG / '    ' /

      INTEGER      ETUNIT              ! extraterrestrial rad io unit
      INTEGER      IOST                ! io status
      INTEGER      IWL                 ! wavelength index
      INTEGER      NWL                 ! # of wlbands (infile)
      INTEGER      NWLIN               ! # of wlbands (infile)

      REAL         FACTOR              ! multiplying factor for F
      REAL         WLIN( MXWLIN )      ! wl for input ET data

C...........EXTERNAL FUNCTIONS and their descriptions:

      INTEGER      JUNIT               ! used to get next IO unit #

C*********************************************************************
C     begin body of subroutine READET

C...open and read the wavelength bands and extraterrestrial radiation

      CALL NAMEVAL ( ETFILE, EQNAME )
      ETUNIT = JUNIT( )

      OPEN( UNIT = ETUNIT,
     &      FILE = EQNAME,
     &      STATUS = 'OLD',
     &      IOSTAT = IOST )

C...check for open errors

      IF ( IOST .NE. 0 ) THEN
        MSG = 'Could not open the ET data file'
        CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT1 )
      END IF

      WRITE( 6, 2001 ) ETUNIT, EQNAME

C...get type of data (e.g. centered, beginning, ending wavelength

101   CONTINUE

      READ( ETUNIT, 1003, IOSTAT = IOST ) TYPE

C...check for read errors

      IF ( IOST .NE. 0 ) THEN
        MSG = 'Errors occurred while reading TYPE from ET file'
        CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT1 )
      END IF

      IF ( TYPE .EQ. '!' ) GO TO 101

C...read the factor to multiply irradiance by

      READ( ETUNIT, 1005, IOSTAT = IOST ) FACTOR

C...check for read errors

      IF ( IOST .NE. 0 ) THEN
        MSG = 'Errors occurred while reading FACTOR from ET file'
        CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT1 )
      END IF

C...initialize arrays

      DO IWL = 1, MXWL
        WLIN( IWL ) = 0.0
        F   ( IWL ) = 0.0
      END DO

C...loop over the number of wavelengths and continue reading

      IWL = 0
201   CONTINUE

C...read the wavelength band data

        IWL = IWL + 1
        READ( ETUNIT, *, IOSTAT = IOST ) WLIN( IWL ), F( IWL )
        F( IWL ) = F( IWL ) * FACTOR

C...check for read errors

        IF ( IOST .GT. 0 ) THEN
          MSG = 'Errors occurred while reading WL,F from ET file'
          CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT1 )
        END IF

C...end loop if we reach EOF, otherwise continue looping

      IF ( IOST .EQ. 0 ) GO TO 201

C...adjust loop counter index index and close file

      NWLIN = IWL - 1
      CLOSE( ETUNIT )

      WRITE( 6, 2003 ) NWLIN

C...determine wl intervals for CENTERED WLBAND data

      IF ( TYPE .EQ. 'C' ) THEN

        NWL = NWLIN
        MIDWL( 1 ) = WLIN( 1 )
        STWL ( 1 ) = 0.5 * ( ( 3.0 * WLIN( 1 ) ) -  WLIN( 2 ) )
        ENDWL( 1 ) = 0.5 * ( WLIN( 1 ) + WLIN( 2 ) )
          
        DO IWL = 2, NWLIN-1
          MIDWL( IWL ) = WLIN( IWL )
          STWL ( IWL ) = 0.5 * ( WLIN( IWL ) + WLIN ( IWL - 1 ) )
          ENDWL( IWL ) = 0.5 * ( WLIN( IWL ) + WLIN ( IWL + 1 ) )
        END DO

        MIDWL( NWL ) = WLIN( NWLIN )
        STWL ( NWL ) = 0.5 * ( WLIN( NWLIN - 1 ) + WLIN( NWLIN ) )
        ENDWL( NWL ) = 0.5 * ( ( 3.0 * WLIN( NWLIN ) )
     &               - WLIN( NWLIN - 1 ) )

C...determine wl intervals for BEGINNING WLBAND data

      ELSE IF ( TYPE .EQ. 'B' ) THEN

        NWL = NWLIN - 1

        DO IWL = 1, NWLIN - 1
          STWL ( IWL ) = WLIN( IWL )
          MIDWL( IWL ) = 0.5 * ( WLIN( IWL ) + WLIN( IWL + 1 ) )
          ENDWL( IWL ) = WLIN( IWL + 1 )
        END DO

C...determine wl intervals for ENDING WLBAND data

      ELSE IF ( TYPE .EQ. 'E' ) THEN

        NWL = NWLIN - 1

        DO IWL = 2, NWLIN
          STWL ( IWL - 1 ) = WLIN( IWL - 1 )
          MIDWL( IWL - 1 ) = 0.5 * ( WLIN( IWL - 1 ) + WLIN( IWL ) )
          ENDWL( IWL - 1 ) = WLIN( IWL )
        END DO

C...stop program if wavelength data type not found

      ELSE

        MSG = 'Unrecognized spectra type in ' // PNAME
        CALL M3EXIT( PNAME, 0, 0, MSG, XSTAT2 )

      END IF

C...formats

1001  FORMAT( A16 )
1003  FORMAT( A1 )
1005  FORMAT( /, 4X, F10.1 )

2001  FORMAT( 1X, '...Opening File on UNIT ', I2, /, 1X, A255, / )
2003  FORMAT( 1X, '...Data for ', I4, ' wavelengths read from file',
     &        // )

      RETURN
      END
