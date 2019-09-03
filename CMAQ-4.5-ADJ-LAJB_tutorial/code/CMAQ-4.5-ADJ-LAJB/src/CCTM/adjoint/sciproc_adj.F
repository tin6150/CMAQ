
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
      SUBROUTINE SCIPROC_ADJ ( LGRID, JDATE, JTIME, TSTEP, ASTEP, LAST )

C-----------------------------------------------------------------------
C Function:
C    ->Controls all of the physical and chemical adjoint processes for a grid
C    ->Operator splitting symmetric around chemistry
C    ->Designed for use with sensitivity analysis

C Preconditions:
C    Dates and times represented YYYYDDD:HHMMSS.
C    No "skipped" dates and times.  All boundary input variables (layered or
C    non-layered) have the same perimeter structure with a thickness of NTHIK

C Subroutines and functions called:
C    All physical and chemical subroutines,
C    VDIFF_ADJ, XADV_ADJ, YADV_ADJ, ZADV_ADJ, HDIFF_ADJ

C Revision History:
C    07 Apr 07 K.Singh & Sandu A.: built SCIPROC_CADJ subroutine to
C           carry out science process adjoint calculations for sensitivity
C	    analysis
C    04 Sep 13 Lucas A. J. Bastien: renaming of some files and subroutines.
C    23 Sep 13 Lucas A. J. Bastien: Now there are FORTRAN variables that
C                                   control whether different processes
C                                   (vertical and horizontal diffusion
C                                   and advection, chemistry) are taken
C                                   into account or not. These variables
C                                   are among the RTO_* variables (RTO
C                                   for run time options), located in
C                                   the module ADJPRM, and read from the
C                                   environment.
C    08 Oct 13 Lucas A. J. Bastien: Control of whether horizontal
C                                   advection is run or not is now split
C                                   between advection in the x direction
C                                   and advection in the y direction
C                                   (removed the variable RTO_HADV and
C                                   added the variables RTO_XADV and
C                                   RTO_YADV).
C    15 Nov 13 Lucas A. J. Bastien: Fixed call condition to ZADV. Added
C                                   call to forcing term. I am still
C                                   confused by what needs RHOJ. Maybe
C                                   VDIFF_ADJ does. In which case need
C                                   to make RHOJ be read when VDIFF_ADJ
C                                   is selected, even though no
C                                   advection is selected. Note that at
C                                   this point I am not sure what is
C                                   correct, so this subroutine might
C                                   need appropriate fixing once I know
C                                   more.
C    24 Jul 14 Lucas A. J. Bastien: Removed RTO_* options that
C                                   corresponded to mechanism selection
C                                   (I'm not sure how to deal with
C                                   couple/decouple when only a few
C                                   mechanisms are selected). Cleaned up
C                                   the code. Now DBUFF is explicitely
C                                   deallocated when not needed. DBUFF
C                                   is also allocated to receive only
C                                   one variable. When RHOJ is read,
C                                   only that variable is read, as
C                                   opposed to all variables.
C    25 Jul 14 Lucas A. J. Bastien: Changed the XSTAT1 (file I/O error)
C                                   into XSTAT2 (execution error) where
C                                   appropriate. See PARMS3.EXT in the
C                                   IOAPI source code for more
C                                   information on these error codes.
C    14 Aug 14 Lucas A. J. Bastien: Added support for restart runs,
C                                   independently for forward and
C                                   backward runs. Also removed EMGRID
C                                   and everything associated with it
C                                   (not used).
C    25 Feb 14 Lucas A. J. Bastien: used JDATE/JTIME in subroutines
C                                   HDIFF_ADJ, VDIFF_ADJ, ZADV_ADJ so
C                                   that meteorological data is read at
C                                   the correct time (see VT code
C                                   changes for more information)
C-----------------------------------------------------------------------

      USE PCGRID_DEFN  ! inherits GRID_CONF and CGRID_SPCS
      USE ADJPRM       ! Adjoint parameters

      IMPLICIT NONE

C Include files:

      INCLUDE SUBST_GC_SPC      ! gas chemistry species table
      INCLUDE SUBST_IOPARMS     ! I/O parameters definitions
      INCLUDE SUBST_IODECL      ! I/O definitions and declarations
      INCLUDE SUBST_PACTL_ID    ! PA control parameters
      INCLUDE SUBST_FILES_ID    ! I/O definitions and declarations

C Arguments:
      REAL, POINTER :: LGRID( :,:,:,: ) ! adjoint variable
      INTEGER       :: JDATE      ! current model date, coded YYYYDDD
      INTEGER       :: JTIME      ! current model time, coded HHMMSS
      INTEGER       :: TSTEP( 2 ) ! time step vector (HHMMSS)
                                  ! TSTEP(1) = local output step
                                  ! TSTEP(2) = sciproc sync. step (chem)
!     INTEGER      ASTEP( NLAYS ) ! layer advection time step
      INTEGER       :: ASTEP( : ) ! layer advection time step
      LOGICAL       :: LAST       ! Flag for last iteration

C Local Variables:

      CHARACTER( 16 ) :: PNAME = "SCIPROC_ADJ"
      LOGICAL, SAVE   :: FIRSTIME = .TRUE.
      LOGICAL, SAVE   :: XFIRST
      CHARACTER( 36 ) :: NMSG = "After NEXTIME: returned JDATE, JTIME"
      INTEGER, SAVE   :: LOGDEV

      INTEGER :: SDATE ! current science process date, coded YYYYDDD
      INTEGER :: STIME ! current science process time, coded HHMMSS

      CHARACTER( 80 ) :: MSG

      INTERFACE
         SUBROUTINE RD_L4CHK ( CGRID, JDATE, JTIME )
            IMPLICIT NONE
            REAL, INTENT(INOUT) :: CGRID( :,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
         END SUBROUTINE RD_L4CHK
         SUBROUTINE CHEM_ADJ ( LGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: LGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE CHEM_ADJ
         SUBROUTINE FORCING_ADJ( LGRID, TSTEP, JDATE, JTIME )
            REAL, POINTER             :: LGRID( :,:,:,: )
            INTEGER, INTENT(IN)       :: TSTEP(2)
            INTEGER, INTENT(IN)       :: JDATE, JTIME
         END SUBROUTINE FORCING_ADJ
         SUBROUTINE HDIFF_ADJ ( LGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: LGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE HDIFF_ADJ
         SUBROUTINE ZADV_ADJ ( LGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: LGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE ZADV_ADJ
         SUBROUTINE XADV_ADJ ( LGRID, JDATE, JTIME, TSTEP, ASTEP )
            IMPLICIT NONE
            REAL, POINTER             :: LGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
            INTEGER, INTENT( IN )     :: ASTEP( : )
         END SUBROUTINE XADV_ADJ
         SUBROUTINE YADV_ADJ ( LGRID, JDATE, JTIME, TSTEP, ASTEP )
            IMPLICIT NONE
            REAL, POINTER             :: LGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
            INTEGER, INTENT( IN )     :: ASTEP( : )
         END SUBROUTINE YADV_ADJ
         SUBROUTINE VDIFF_ADJ ( LGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: LGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE VDIFF_ADJ

      END INTERFACE

C-----------------------------------------------------------------------

      IF (FIRSTIME) THEN

         FIRSTIME = .FALSE.

         LOGDEV = INIT3 ()

C     Whether to start with x or y advection for the first iteration

         XFIRST = XFIRST_BWD

      END IF ! FIRSTIME

      SDATE = JDATE
      STIME = JTIME

      CALL NEXTIME ( JDATE, JTIME, -TSTEP( 2 ) )
      WRITE( LOGDEV,'(/ 5X, A, I8, I7.6)' ) NMSG, JDATE, JTIME

c$$$  CALL AERO ( CGRID, JDATE, JTIME, TSTEP )

      CALL FORCING_ADJ(LGRID, TSTEP, JDATE, JTIME)

      CALL CHEM_ADJ ( LGRID, JDATE, JTIME, TSTEP )

c$$$  CALL CLDPROC ( CGRID, JDATE, JTIME, TSTEP )


c$$$  CALL PING ( JDATE, JTIME, TSTEP )


C     Physical Processes for any Grid
      CALL HDIFF_ADJ ( LGRID, JDATE, JTIME, TSTEP )

C     Read RHOJ from CONC_L4CHK for JDATE, JTIME

      CALL RD_L4CHK(LGRID(:,:,:,NSPCSD), JDATE, JTIME)

      CALL ZADV_ADJ  ( LGRID, JDATE, JTIME, TSTEP )

      IF ( XFIRST ) THEN

         XFIRST = .FALSE.

         CALL XADV_ADJ ( LGRID, SDATE, STIME, TSTEP, ASTEP )
         CALL YADV_ADJ ( LGRID, SDATE, STIME, TSTEP, ASTEP )

      ELSE

         XFIRST = .TRUE.

         CALL YADV_ADJ ( LGRID, SDATE, STIME, TSTEP, ASTEP )
         CALL XADV_ADJ ( LGRID, SDATE, STIME, TSTEP, ASTEP )

      END IF

      CALL VDIFF_ADJ ( LGRID, JDATE, JTIME, TSTEP )

      IF (LAST) THEN
         PRINT'(A, 1X, L1)', "SCIPROC_ADJ XFIRST FOR RESTART:", XFIRST
      END IF

      RETURN
      END
