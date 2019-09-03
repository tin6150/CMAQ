
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

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      SUBROUTINE WR_L2CHK ( CGRID, JDATE, JTIME )

C Note (Lucas A. J. Bastien, June 1st 2015): this subroutine writes
C species concentrations and RHOJ into the L2CHK file. This subroutine
C is based on .../CCTM/driver/ctm/wr_conc.F. It is basically the exact
C same subroutine with added code which writes the variable RHOJ into
C the L2CHK file once all the other variables are written to the file.

C Revision History of .../CCTM/driver/ctm/wr_conc.F:
C   10/13/99 David Wong at LM
C      -- Called from driver, where CGRID is a pointer (subset) of PCGRID.
C         Necessary, to keep from referencing parts of PCGRID that don't
C         belong to CGRID.
C    1/31/2000 Jeff Young
C      -- f90 memory mgmt
C   Jeff - Dec 00 - move CGRID_MAP into f90 module
C   Jeff - Feb 01 - assumed shape arrays
C   30 Mar 01 J.Young: dyn alloc - Use HGRD_DEFN; DBUFF for WRITE3
C   31 Jan 05 J.Young: dyn alloc - establish both horizontal & vertical
C                      domain specifications in one module
C-----------------------------------------------------------------------

      USE GRID_CONF             ! horizontal & vertical domain specifications
      USE CGRID_SPCS            ! CGRID species number and offsets

      IMPLICIT NONE

C Include Files

      INCLUDE SUBST_GC_SPC      ! gas chemistry species table
      INCLUDE SUBST_AE_SPC      ! aerosol species table
      INCLUDE SUBST_NR_SPC      ! non-reactive species table
      INCLUDE SUBST_TR_SPC      ! tracer species table
      INCLUDE SUBST_GC_CONC     ! gas chem conc file species and map table
      INCLUDE SUBST_AE_CONC     ! aerosol conc file species and map table
      INCLUDE SUBST_IOPARMS     ! I/O parameters definitions
#include      SUBST_IODECL      # I/O definitions and declarations
      INCLUDE SUBST_FILES_ID    ! File definitions

C     Dummy arguments

      REAL, POINTER, INTENT(IN) :: CGRID( :,:,:,: )
      INTEGER, INTENT(IN) :: JDATE ! current model date, coded YYYYDDD
      INTEGER, INTENT(IN) :: JTIME ! current model time, coded HHMMSS

C Local variables:

      INTEGER      SPC, VAR     ! species loop counters

      CHARACTER( 16 ) :: PNAME = 'WR_L2CHK'
      CHARACTER( 96 ) :: XMSG = ' '

      INTEGER, SAVE :: LOGDEV       ! FORTRAN unit number for log file
      LOGICAL, SAVE :: FIRSTIME = .TRUE.

C-----------------------------------------------------------------------

      IF ( FIRSTIME ) THEN

         FIRSTIME = .FALSE.
         LOGDEV = INIT3 ()

         CALL CGRID_MAP( NSPCSD, GC_STRT, AE_STRT, NR_STRT, TR_STRT )

         IF ( .NOT. OPEN3( CONC_L2CHK, FSRDWR3, PNAME ) ) THEN
            XMSG = 'Could not open ' // CONC_L2CHK // ' file for update'
         END IF

      END IF

      DO SPC = 1, N_GC_CONC
         VAR = GC_STRT - 1 + GC_CONC_MAP( SPC )

         IF ( .NOT. WRITE3( CONC_L2CHK, GC_CONC( SPC ), JDATE, JTIME,
     &      CGRID( 1:MY_NCOLS,1:MY_NROWS,1:NLAYS,VAR ) ) ) THEN
            XMSG = 'Could not write ' // GC_CONC( SPC ) // ' to '
     &            // CONC_L2CHK
            CALL M3EXIT( PNAME, JDATE, JTIME, XMSG, XSTAT1 )
         END IF

      END DO

      DO SPC = 1, N_AE_CONC
         VAR = AE_STRT - 1 + AE_CONC_MAP( SPC )

         IF ( .NOT. WRITE3( CONC_L2CHK, AE_CONC( SPC ), JDATE, JTIME,
     &      CGRID( 1:MY_NCOLS,1:MY_NROWS,1:NLAYS,VAR ) ) ) THEN
            XMSG = 'Could not write ' // AE_CONC( SPC ) // ' to '
     &            // CONC_L2CHK
            CALL M3EXIT( PNAME, JDATE, JTIME, XMSG, XSTAT1 )
         END IF

      END DO

      DO SPC = 1, N_NR_SPC
         VAR = NR_STRT - 1 + SPC

         IF ( .NOT. WRITE3( CONC_L2CHK, NR_SPC( SPC ), JDATE, JTIME,
     &      CGRID( 1:MY_NCOLS,1:MY_NROWS,1:NLAYS,VAR ) ) ) THEN
            XMSG = 'Could not write ' // NR_SPC( SPC ) // ' to '
     &            // CONC_L2CHK
            CALL M3EXIT( PNAME, JDATE, JTIME, XMSG, XSTAT1 )
         END IF

      END DO

      DO SPC = 1, N_TR_SPC
         VAR = TR_STRT - 1 + SPC

         IF ( .NOT. WRITE3( CONC_L2CHK, TR_SPC( SPC ), JDATE, JTIME,
     &      CGRID( 1:MY_NCOLS,1:MY_NROWS,1:NLAYS,VAR ) ) ) THEN
            XMSG = 'Could not write ' // TR_SPC( SPC ) // ' to '
     &            // CONC_L2CHK
            CALL M3EXIT( PNAME, JDATE, JTIME, XMSG, XSTAT1 )
         END IF

      END DO

C     Write variable RHOJ to file

      IF ( .NOT. WRITE3( CONC_L2CHK, "RHOJ", JDATE, JTIME,
     &     CGRID( 1:MY_NCOLS,1:MY_NROWS,1:NLAYS,NSPCSD ) ) ) THEN
         XMSG = 'Could not write RHOJ to ' // CONC_L2CHK
         CALL M3EXIT( PNAME, JDATE, JTIME, XMSG, XSTAT1 )
      END IF

      WRITE( LOGDEV, '( /5X, 3( A, :, 1X ), I8, ":", I6.6 )' )
     &     'Timestep written to', CONC_L2CHK,
     &     'for date and time', JDATE, JTIME

      RETURN
      END SUBROUTINE WR_L2CHK
