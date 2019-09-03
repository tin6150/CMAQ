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

      SUBROUTINE WR_ADVSTEPMIN(NLAYS, TSTEP, ASTEP, NREPS)

C     This subroutine writes in a text file the values of TSTEP, ASTEP,
C     and NREPS. This subroutine was written to write the outputs of
C     the subroutine ADVSTEPMIN (called in the main forward loop) so
C     that these values are readily available for subsequent adjoint
C     runs. The values are written to the file which physical name on
C     disc is stored in the variable FIL_ASTEP.

C     Modules

      USE ADJPRM                 ! Adjoint parameters

      IMPLICIT NONE

C     Include files

      INCLUDE SUBST_IOPARMS     ! I/O parameters definitions

C     Dummy variables

      INTEGER, INTENT(IN) :: NLAYS        ! Number of vertical layers
      INTEGER, INTENT(IN) :: TSTEP(2)     ! Output time step: TSTEP(1);
                                          ! and synchronization time
                                          ! step: TSTEP(2)
      INTEGER, INTENT(IN) :: ASTEP(NLAYS) ! Advection time step for each
                                          ! layer
      INTEGER, INTENT(IN) :: NREPS        ! Number of synchronization
                                          ! time steps per output time
                                          ! steps
C     Other variables

      CHARACTER( 16 ) :: PNAME = "WR_ADVSTEPMIN"
      CHARACTER( 96 ) :: MSG ! Warning/Error message
      INTEGER :: LUN         ! Logical unit number of text file
      INTEGER :: I           ! Iteration variable
      INTEGER :: ERR         ! Error status when opening file

C     ------------------------------------------------------------------

C     Find a good logical unit number and open file for writing

      CALL FIND_LUN(LUN)

      OPEN(UNIT=LUN, FILE=FIL_ASTEP, ACTION="WRITE", IOSTAT=ERR)

      IF (ERR .NE. 0) THEN
         MSG = "Cannot open advstepmin file for writing"
         CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT1 )
      END IF

C     Write NLAYS, TSTEP, and NREPS, with their keywords

      WRITE(LUN,'(A5, 1X, I10)') "NLAYS", NLAYS
      WRITE(LUN,'(A5, 1X, I10, 1X, I10)') "TSTEP", TSTEP(1), TSTEP(2)
      WRITE(LUN,'(A5, 1X, I10)') "NREPS", NREPS

C     Write the values in ASTEP, with their index

      DO I = 1, NLAYS
         WRITE(LUN,'(I10, 1X, I10)') I, ASTEP(I)
      END DO

C     Close and return

      CLOSE(LUN)

      RETURN

      END SUBROUTINE WR_ADVSTEPMIN
