C     Portions of Models-3/CMAQ software were developed or based on
C     information from various groups: Federal Government employees,
C     contractors working on a United States Government contract, and
C     non-Federal sources (including research institutions).  These
C     research institutions have given the Government permission to use,
C     prepare derivative works, and distribute copies of their work in
C     Models-3/CMAQ to the public and to permit others to do so.  EPA
C     therefore grants similar permissions for use of the Models-3/CMAQ
C     software, but users are requested to provide copies of derivative
C     works to the Government without restrictions as to use by others.
C     Users are responsible for acquiring their own copies of commercial
C     software associated with Models-3/CMAQ and for complying with
C     vendor requirements.  Software copyrights by the MCNC
C     Environmental Modeling Center are used with their permissions
C     subject to the above restrictions.
C
C     AUTHOR: Lucas A. J. Bastien

      SUBROUTINE RD_ADVSTEPMIN(NLAYS, TSTEP, ASTEP, NREPS)

C     This subroutine reads in a text file the values of TSTEP, ASTEP,
C     and NREPS. This subroutine was written to read the outputs of the
C     subroutine ADVSTEPMIN (called in the main forward loop) so that we
C     can make sure we use the same values in the forward and adjoint
C     runs. The values are read from the file which physical name on
C     disc is stored in the variable FIL_ASTEP.

C     Modules

      USE ADJPRM                ! Adjoint parameters

      IMPLICIT NONE

C     Include files

      INCLUDE SUBST_IOPARMS     ! I/O parameters definitions

C     Dummy variables

      INTEGER, INTENT(IN)    :: NLAYS        ! Number of vertical layers
      INTEGER, INTENT(INOUT) :: TSTEP(2)     ! Output time step:
                                             ! TSTEP(1); and
                                             ! synchronization time
                                             ! step: TSTEP(2)
      INTEGER, INTENT(OUT)   :: ASTEP(NLAYS) ! Advection time step for
                                             ! each layer
      INTEGER, INTENT(OUT)   :: NREPS        ! Number of synchronization
                                             ! time steps per output
                                             ! time steps
C     Other variables

      CHARACTER( 16 ) :: PNAME = "RD_ADVSTEPMIN"
      CHARACTER( 5 )  :: KEYWORD    ! To store read keywords
      CHARACTER( 96 ) :: MSG        ! Warning/Error message
      INTEGER         :: LUN        ! Logical unit number of text file
      INTEGER         :: I, J       ! Iteration variables
      INTEGER         :: TMP_NLAYS  ! Temporary NLAYS
      INTEGER         :: TMP_TSTEP1 ! Temporary TSTEP(1)
      INTEGER         :: ERR        ! Error status when opening file

C     ------------------------------------------------------------------

C     Find a good logical unit number and open file for reading

      CALL FIND_LUN(LUN)

      OPEN(UNIT=LUN, FILE=FIL_ASTEP, ACTION="READ", IOSTAT=ERR)

      IF (ERR .NE. 0) THEN
         MSG = "Cannot open advstepmin file for reading"
         CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT1 )
      END IF

C     Read NLAYS

      READ(LUN,'(A5, 1X, I10)') KEYWORD, TMP_NLAYS

      IF (KEYWORD .NE. "NLAYS") THEN
         MSG = "Expecting keyword NLAYS, got " // KEYWORD
         CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2 )
      END IF

C     NLAYS read from file should be the same as the current value

      IF (TMP_NLAYS .NE. NLAYS) THEN
         MSG = "Read NLAYS does not match current value"
         CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2 )
      END IF

C     Read TSTEP

      READ(LUN,'(A5, 1X, I10, 1X, I10)') KEYWORD, TMP_TSTEP1, TSTEP(2)

      IF (KEYWORD .NE. "TSTEP") THEN
         MSG = "Expecting keyword TSTEP, got " // KEYWORD
         CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2 )
      END IF

C     TSTEP(1) read from file should be the same as the current value

      IF (TMP_TSTEP1 .NE. TSTEP(1)) THEN
         MSG = "Read TSTEP(1) does not match current value"
         CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2 )
      END IF

C     Read NREPS

      READ(LUN,'(A5, 1X, I10)') KEYWORD, NREPS

      IF (KEYWORD .NE. "NREPS") THEN
         MSG = "Expecting keyword NREPS, got " // KEYWORD
         CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2 )
      END IF

C     Read ASTEP

      DO I = 1, NLAYS

         READ(LUN,'(I10, 1X, I10)') J, ASTEP(I)

         IF (J .NE. I) THEN
            MSG = "Error when reading ASTEP, non-matching indices"
            CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2 )
         END IF

      END DO

C     Close file and return

      CLOSE(LUN)

      RETURN

      END SUBROUTINE RD_ADVSTEPMIN
