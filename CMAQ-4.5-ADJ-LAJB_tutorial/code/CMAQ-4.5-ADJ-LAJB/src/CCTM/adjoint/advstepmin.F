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

      SUBROUTINE ADVSTEPMIN(NLAYS, NSTEPS, STDATE, STTIME, TSTEP,
     &                      ASTEP, NREPS)
C
C     AUTHOR: Lucas A. J. Bastien
C
C     PURPOSE (SUMMARY): This subroutine calculates the minimum
C     advection and synchronization time steps throughout the
C     simulation. It also calculates the corresponding number of
C     synchronization time steps per output time steps.
C
C     PURPOSE (DETAILED): In CMAQ-v4.5, advection and synchronization
C     time steps are re-calculated at each output time step and depend
C     on the meteorology for that time step (the calculation revolves
C     around respecting the CFL criterion). Advection and
C     synchronization time steps can vary with output time steps. Note
C     that for each output time step, one advection time step is
C     calculated for each vertical layer. In CMAQ-v4.5-ADJ, the
C     concentration field is checkpointed at each synchronization time
C     step. Therefore the synchronization time step needs to be constant
C     thoughout the simulation. This subroutine goes through all output
C     time steps, calculates the advection and synchronization time
C     steps for each of the output time steps, and returns the minimum
C     of those advection and synchronization time steps. This subroutine
C     also returns the corresponding number of synchronization time
C     steps per output time steps. This subroutine should be called
C     before creating the checkpoint files (which will use the minimum
C     synchronization time step as time step) and before the forward and
C     backward loops. This subroutine checks that at each new output
C     time step, either all new advection times steps are smaller than
C     the old ones or all new advection times steps are bigger than the
C     old ones (the comparison is done on a per layer basis -- remember
C     that one advection time step is calculated for each layer). If,
C     among the newly calculated advecion time steps, some are smaller
C     than the old ones and some are bigger than the old one (on a per
C     layer basis), then the question "are new time steps smaller than
C     the old ones": cannot be answered by "yes" or "no". In that case,
C     the subroutine exits with error. To fix that, the user should
C     reduce the value of the environment variable SIGMA_SYNC_TOP at run
C     time.

      IMPLICIT NONE

C     Include files

      INCLUDE SUBST_IOPARMS ! I/O parameters definitions

C     Dummy arguments

      INTEGER, INTENT(IN) :: NSTEPS        ! Number of output time steps
      INTEGER, INTENT(IN) :: NLAYS         ! Number of vertical layers
      INTEGER, INTENT(IN) :: STDATE        ! Start date, format YYYYDDD
      INTEGER, INTENT(IN) :: STTIME        ! Start time, format HHMMSS
      INTEGER, INTENT(INOUT) :: TSTEP(2)   ! Output time step: TSTEP(1);
                                           ! and synchronization time
                                           ! step: TSTEP(2)
      INTEGER, INTENT(OUT) :: ASTEP(NLAYS) ! Advection time step for
                                           ! each layer
      INTEGER, INTENT(OUT) :: NREPS        ! Number of synchronization
                                           ! time steps per output time
                                           ! steps

C     Local variables

      CHARACTER(16) :: PNAME  ! Subroutine name
      INTEGER       :: STATUS ! Return status
      CHARACTER(70) :: MSG    ! Status/warning/error message
      INTEGER :: TMP_TSTEP(2) ! Temporary place holder for newly
                              ! calculated TSTEP
      INTEGER, ALLOCATABLE :: TMP_ASTEP(:) ! Temporary place holder for
                                           ! newly calculated ASTEP
      INTEGER :: TMP_NREPS    ! Temporary place holder for newly
                              ! calculated NREPS
      INTEGER :: JDATE        ! Current date, format YYYYDDD
      INTEGER :: JTIME        ! Current time, format HHMMSS
      INTEGER :: ISTEP        ! Variable to iterate over output time
                              ! steps
      INTEGER :: J            ! Iteration variable
      LOGICAL :: NORMAL       ! Is everything as expected?
      LOGICAL :: ISONEBIGGER  ! Compare old and new advection time step
      LOGICAL :: ISONESMALLER ! Compare old and new advection time step

      INTERFACE
C     Note (Lucas A. J. Bastien): ASTEP is declared as INTENT(IN) in
C     interfaces in the rest of the code while it seems to me that it
C     should be declared as INTENT(OUT) since ASTEP is being given
C     values in ADVSTEP. I am not sure about why it is INTENT(IN) in
C     interfaces in the rest of the code but I will do the same here.
         SUBROUTINE ADVSTEP ( JDATE, JTIME, TSTEP, ASTEP, NREPS )
            IMPLICIT NONE
            INTEGER, INTENT(IN)  :: JDATE, JTIME
            INTEGER, INTENT(IN)  :: TSTEP(2)
            INTEGER, INTENT(IN)  :: ASTEP(:)
            INTEGER, INTENT(OUT) :: NREPS
         END SUBROUTINE ADVSTEP
      END INTERFACE

C     ------------------------------------------------------------------

      PNAME = "ADVSTEPMIN"

C     Allocate the temporary buffer for ASTEP

      ALLOCATE ( TMP_ASTEP( NLAYS ), STAT = STATUS )
      IF ( STATUS .NE. 0 ) THEN
         MSG = 'TMP_ASTEP memory allocation failed'
         CALL M3EXIT ( PNAME, JDATE, JTIME, MSG, XSTAT2 )
      END IF

C     Initialize

      JDATE = STDATE
      JTIME = STTIME
      TMP_TSTEP(1) = TSTEP(1)
      TSTEP(2) = 999999
      ASTEP = 999999
      NREPS = -1

C     Calculate sync and adv time steps for each time step

      DO ISTEP = 1, NSTEPS

         CALL ADVSTEP ( JDATE, JTIME, TMP_TSTEP, TMP_ASTEP, TMP_NREPS )

C     Check that TSTEP(1) has not changed

         IF ( TMP_TSTEP(1) .NE. TSTEP(1) ) THEN
            MSG = "TSTEP(1) has changed"
            CALL M3EXIT ( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         END IF

C     Either all new advection time steps are smaller/equal to the old
C     ones, or all time new advection time steps are bigger/equal to the
C     old ones. If it is not the case, exit with error.

         NORMAL = .TRUE.
         ISONESMALLER = .FALSE.
         ISONEBIGGER = .FALSE.

         J = 1
         DO WHILE ( (J .LE. NLAYS) .AND. NORMAL )
            IF ( TMP_ASTEP(J) .LT. ASTEP(J) ) ISONESMALLER = .TRUE.
            IF ( TMP_ASTEP(J) .GT. ASTEP(J) ) ISONEBIGGER = .TRUE.
            NORMAL = ( .NOT. (ISONESMALLER .AND. ISONEBIGGER) )
            J = J+1
         END DO

         IF (TMP_TSTEP(2) .LT. TSTEP(2)) THEN
            NORMAL = NORMAL .AND. ( .NOT. ISONEBIGGER ) .AND.
     &                            (TMP_NREPS .GT. NREPS)
         END IF

         IF (TMP_TSTEP(2) .GT. TSTEP(2)) THEN
            NORMAL = NORMAL .AND. ( .NOT. ISONESMALLER ) .AND.
     &                            (TMP_NREPS .LT. NREPS)
         END IF

         IF (TMP_TSTEP(2) .EQ. TSTEP(2)) THEN
            NORMAL = NORMAL .AND. (TMP_NREPS .EQ. NREPS)
         END IF

         IF ( .NOT. NORMAL ) THEN
            MSG = "Something wrong. Maybe try lowering SIGMA_SYNC_TOP?"
            CALL M3EXIT ( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         END IF

C     Record new time step if necessary

         IF ( ISONESMALLER ) THEN
            TSTEP(2) = TMP_TSTEP(2)
            DO J=1,NLAYS
               ASTEP(J) = TMP_ASTEP(J)
            END DO
            NREPS = TMP_NREPS
         END IF

C     Advance time step

         CALL NEXTIME( JDATE, JTIME, TSTEP(1) )

      END DO ! ISTEP

C     Deallocate TMP_ASTEP

      DEALLOCATE ( TMP_ASTEP, STAT = STATUS )
      IF ( STATUS .NE. 0 ) THEN
         MSG = 'TMP_ASTEP memory deallocation failed'
         CALL M3EXIT ( PNAME, JDATE, JTIME, MSG, XSTAT2 )
      END IF

C     Check that TSTEP(1) has not changed

      IF (TMP_TSTEP(1) .NE. TSTEP(1)) THEN
         MSG = "TSTEP(1) has been changed"
         CALL M3EXIT ( PNAME, JDATE, JTIME, MSG, XSTAT2 )
      END IF

      RETURN

      END SUBROUTINE ADVSTEPMIN
