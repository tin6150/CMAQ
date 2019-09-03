
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
      PROGRAM  DRIVER

C-----------------------------------------------------------------------
C Function:
C     -> CTM driver for SENSITIVITY ANALYSIS
C     -> SENSITIVITY TEST: Run this driver to generate the adjoint
C        trajectory for species under consideration. To change the
C        specie number or the area under consideration, go to
C        "define_receptor.F" file.

C CAUTION:
C     -> Driver designed to perform Sensitivity test with ozone

C CHECKPOINT FILES:
C     CONC_CHK   = Current concentration

C Subroutines and functions called:
C     INITSCEN, ADVSTEP, M3EXIT, WRITE3
C     SUBDRIVER -> performs forward and/or adjoint model run to create
C     the trajectory
C
C Revision History:
C
C     Kumaresh Singh & Sandu,A. Apr 07 - Added to perform Sensitivity test
C
C     Lucas A. J. Bastien (04th September 2013). Renaming of some files
C     and subroutines.
C
C     Lucas A. J. Bastien (23rd September 2013). Combined driver with
C     subdriver. The advection and synchronization time steps are now
C     calculated before the forward and backward loops (subroutine
C     ADVSTEPMIN) and are constant throughout the simulation. Sequence
C     to create and check headers of non-CHK and CHK files is
C     modified. Now, the non-CHK files are created, then their headers
C     are checked, then the advection and synchronization time steps are
C     calculated, then the CHK files are created, then their headers are
C     checked. Also added a call to read runtime, receptor, and other
C     useful options and parameters (subroutine READ_ADJPRM). Added
C     deallocation of arrays that are allocated here.
C
C     Lucas A. J. Bastien (8th October 2013). Added switches to control
C     whether checkpointing should be done or not. This behavior is
C     controlled by the variable RTO_CHK. This variable is set by the
C     user at run time using the environment variable of the same name.
C
C     Lucas A. J. Bastien (15th November 2013). I moved NSTEPS, STDATE,
C     and STTIME to module ADJPRM (there are needed in FORCING_ADJ).
C
C     Lucas A. J. Bastien (08th July 2014). Changed the adjoint main
C     loop so that the integral time of the simulation is exactly the
C     desired length. See notes of March 10 2014 for more details.
C
C     Lucas A. J. Bastien (24th July 2014). Removed support for restart
C     runs. Renamed ADVSTEP_MIN into ADVSTEPMIN. Added writing to and
C     reading from a file of parameters calculated by ADVSTEPMIN.
C
C     Lucas A. J. Bastien (14th August 2014). Added support for restart
C     runs, independently for forward and backward runs. Also removed
C     EMGRID and everything associated with it (not used).
C
C-----------------------------------------------------------------------

C Modules

      USE PCGRID_DEFN           ! inherits HGRD_DEFN and CGRID_SPCS
      USE VGRD_DEFN             ! vertical layer specifications
      USE ADJPRM                ! Adjoint parameters

      IMPLICIT NONE

C Include Files:

!     INCLUDE SUBST_VGRD_ID     ! vertical dimensioning parameters
      INCLUDE SUBST_IOPARMS     ! I/O parameters definitions
      INCLUDE SUBST_IOFDESC     ! file header data structure
      INCLUDE SUBST_IODECL      ! I/O definitions and declarations
      INCLUDE SUBST_FILES_ID    ! I/O definitions and declarations
      INCLUDE SUBST_PACTL_ID    ! PA control parameters

C Load the mechanism COMMON ... (next two INCLUDE files)
      INCLUDE SUBST_RXCMMN      ! chemical mechamism reactions COMMON
      INCLUDE SUBST_RXDATA      ! chemical mechamism reactions DATA
      INCLUDE SUBST_GC_SPC      ! gas chemistry species table

      INCLUDE SUBST_GC_DIFF   ! gas chem diffusion species and map table
      INCLUDE SUBST_AE_DIFF   ! aerosol diffusion species and map table
      INCLUDE SUBST_NR_DIFF   ! non-react diffusion species and map table
      INCLUDE SUBST_TR_DIFF   ! tracer diffusion species and map table

C External Functions (not already declared by IODECL3.EXT):

      INTEGER, EXTERNAL :: ENVINT   ! Gets integer value of environment variable
      INTEGER, EXTERNAL :: INDEX1
      INTEGER, EXTERNAL :: TIME2SEC ! Converts HHMMSS to raw seconds
      CHARACTER( 10 ), EXTERNAL :: HHMMSS ! converts to string
                                          ! "HH:MM:SS"

C Local variables:

      INTEGER :: LOGDEV   ! FORTRAN unit number for log file
      INTEGER :: STATUS
      CHARACTER( 16 ) :: PNAME = "DRIVER"
      CHARACTER( 96 ) :: MSG = " "
      INTEGER :: TSTEP(2) ! time step vector (HHMMSS) TSTEP(1) = output
                          ! step TSTEP(2) = sciproc sync. step (chem)
      INTEGER :: NREPS    ! Number of sincronization time steps
                          ! (i.e. number of TSTEP(2))
      INTEGER :: JDATE    ! current model date, format YYYYDDD
      INTEGER :: JTIME    ! current model time, format HHMMSS
      INTEGER :: N_SPC_DIFF ! Global diffusion species

      INTEGER :: RESDATE, RESTIME, SDATE, STIME
      INTEGER, ALLOCATABLE :: ASTEP(:)

      REAL, POINTER :: CGRID( :,:,:,: )
      REAL, POINTER :: CGRID_AVG( :,:,:,: )
      REAL, POINTER :: LGRID( :,:,:,: )
      REAL, POINTER :: LGRID_AVG( :,:,:,: )

      INTEGER :: IREP, ISTEP, IC, IR, IL, IN

      INTEGER :: PAR_ERR ! Error code from parallel initialization
      REAL :: CLOCK      ! Wall-clock time (sec) at initialization

      LOGICAL :: LAST    ! Flag for last iteration

      INTEGER :: STEPSECS ! Used to calculate ADJ_TOTSTEPS

      DOUBLEPRECISION :: WALLTIME1, WALLTIME2 ! Wall times

      INTEGER :: I_AVG ! Counter to know when to write average data
                       ! (ACONC and AL5CHK files)

      INTEGER :: JDATE_AVG, JTIME_AVG ! When to write into the ACONC file

      INTERFACE
         SUBROUTINE ADJVERBOSE ()
            IMPLICIT NONE
         END SUBROUTINE ADJVERBOSE
         SUBROUTINE ADVSTEPMIN(NLAYS, NSTEPS, STDATE, STTIME, TSTEP,
     &                         ASTEP, NREPS)
            IMPLICIT NONE
            INTEGER, INTENT(IN) :: NSTEPS
            INTEGER, INTENT(IN) :: NLAYS
            INTEGER, INTENT(IN) :: STDATE
            INTEGER, INTENT(IN) :: STTIME
            INTEGER, INTENT(INOUT) :: TSTEP(2)
            INTEGER, INTENT(OUT) :: ASTEP(NLAYS)
            INTEGER, INTENT(OUT) :: NREPS
         END SUBROUTINE ADVSTEPMIN
         SUBROUTINE DEFINE_RECEPTOR ( LGRID )
            IMPLICIT NONE
            REAL, POINTER             :: LGRID( :,:,:,: )
         END SUBROUTINE DEFINE_RECEPTOR
         SUBROUTINE FIND_LUN( LUN )
            IMPLICIT NONE
            INTEGER, INTENT(OUT) :: LUN
         END SUBROUTINE FIND_LUN
         SUBROUTINE INITSCEN ( CGRID, STDATE, STTIME, TSTEP, NSTEPS )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( OUT )    :: STDATE, STTIME
            INTEGER, INTENT( OUT )    :: TSTEP( 2 )
            INTEGER, INTENT( OUT )    :: NSTEPS
         END SUBROUTINE INITSCEN
         SUBROUTINE OPCONC ( CGRID, STDATE, STTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER                 :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )         :: STDATE, STTIME, TSTEP
         END SUBROUTINE OPCONC
         SUBROUTINE PA_INIT ( CGRID, JDATE, JTIME, TSTEP )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
         END SUBROUTINE PA_INIT
         SUBROUTINE PA_OUTPUT ( CGRID, JDATE, JTIME )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
         END SUBROUTINE PA_OUTPUT
         SUBROUTINE RD_ADVSTEPMIN( NLAYS, TSTEP, ASTEP, NREPS )
            IMPLICIT NONE
            INTEGER, INTENT(IN)    :: NLAYS
            INTEGER, INTENT(INOUT) :: TSTEP(2)
            INTEGER, INTENT(OUT)   :: ASTEP(NLAYS)
            INTEGER, INTENT(OUT)   :: NREPS
         END SUBROUTINE RD_ADVSTEPMIN
         SUBROUTINE RD_CHK ( CGRID, JDATE, JTIME )
            IMPLICIT NONE
            REAL, POINTER, INTENT(INOUT) :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
         END SUBROUTINE RD_CHK
         SUBROUTINE RD_L5CHK ( CGRID, JDATE, JTIME )
            IMPLICIT NONE
            REAL, POINTER, INTENT(INOUT) :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
         END SUBROUTINE RD_L5CHK
         SUBROUTINE RD_L5FCHK ( CGRID, JDATE, JTIME )
            IMPLICIT NONE
            REAL, POINTER, INTENT(INOUT) :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
         END SUBROUTINE RD_L5FCHK
         SUBROUTINE SCIPROC ( CGRID, JDATE, JTIME, TSTEP, ASTEP, LAST )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN OUT ) :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 )
            INTEGER, INTENT( IN )     :: ASTEP( : )
            LOGICAL, INTENT( IN )     :: LAST
         END SUBROUTINE SCIPROC
         SUBROUTINE SCIPROC_ADJ ( LGRID, JDATE, JTIME, TSTEP, ASTEP,
     &                            LAST )
            IMPLICIT NONE
            REAL, POINTER             :: LGRID(:,:,:,:)
            INTEGER, INTENT( IN OUT ) :: JDATE, JTIME
            INTEGER, INTENT( IN )     :: TSTEP( 2 ), ASTEP( : )
            LOGICAL, INTENT( IN )     :: LAST
         END SUBROUTINE SCIPROC_ADJ
         SUBROUTINE WR_ADVSTEPMIN( NLAYS, TSTEP, ASTEP, NREPS )
            IMPLICIT NONE
            INTEGER, INTENT(IN) :: NLAYS
            INTEGER, INTENT(IN) :: TSTEP(2)
            INTEGER, INTENT(IN) :: ASTEP(NLAYS)
            INTEGER, INTENT(IN) :: NREPS
         END SUBROUTINE WR_ADVSTEPMIN
         SUBROUTINE WR_CONC ( CGRID, JDATE, JTIME )
            IMPLICIT NONE
            REAL, POINTER             :: CGRID( :,:,:,: )
            INTEGER                   :: JDATE, JTIME
         END SUBROUTINE WR_CONC
         SUBROUTINE WR_CHK ( CGRID, JDATE, JTIME )
            IMPLICIT NONE
            REAL, POINTER, INTENT(IN) :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
         END SUBROUTINE WR_CHK
         SUBROUTINE WR_L5CHK ( CGRID, JDATE, JTIME )
            IMPLICIT NONE
            REAL, POINTER, INTENT(IN) :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
         END SUBROUTINE WR_L5CHK
         SUBROUTINE WR_L5FCHK ( CGRID, JDATE, JTIME )
            IMPLICIT NONE
            REAL, POINTER, INTENT(IN) :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
         END SUBROUTINE WR_L5FCHK
         SUBROUTINE WR_ACONC ( CGRID, JDATE, JTIME )
            IMPLICIT NONE
            REAL, POINTER, INTENT(IN) :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
         END SUBROUTINE WR_ACONC
         SUBROUTINE WR_AL5CHK ( CGRID, JDATE, JTIME )
            IMPLICIT NONE
            REAL, POINTER, INTENT(IN) :: CGRID( :,:,:,: )
            INTEGER, INTENT( IN )     :: JDATE, JTIME
         END SUBROUTINE WR_AL5CHK
      END INTERFACE

C-----------------------------------------------------------------------

C     ==========
C     INITIALIZE
C     ==========

C     Get number of species, and starting indices for CGRID array.

      CALL CGRID_MAP ( NSPCSD, GC_STRT, AE_STRT, NR_STRT, TR_STRT )

C     Global diffusion species

      N_SPC_DIFF = N_GC_DIFF + N_AE_DIFF + N_NR_DIFF + N_TR_DIFF

C     Start up processor communication and define horizontal domain
C     decomposition and vertical layer structure

      CALL PAR_INIT( PNAME, NSPCSD, CLOCK, PAR_ERR )

      IF ( PAR_ERR .NE. 0 ) THEN
         MSG = 'Error in PAR_INIT'
         CALL M3EXIT ( PNAME, 0, 0, MSG, XSTAT2 )
      END IF

C     Initialize IOAPI log file(s)
      LOGDEV = INIT3 ()

C     Print git verbose

      CALL GIT_VERBOSE()

C     Read options and parameters of ADJPRM from the environment and
C     write verbose to log file.

      CALL READ_ADJPRM ()
      CALL ADJVERBOSE ()

C     Initialize PCGRID

      IF ( .NOT. PCGRID_INIT() ) THEN
         MSG = 'Failure defining horizontal domain'
         CALL M3EXIT ( PNAME, 0, 0, MSG, XSTAT2 )
      END IF

      CGRID => PCGRID(1:MY_NCOLS,1:MY_NROWS,:,:) ! required for PinG

C     We don't deal with checkpoint files until later

      CHKPROC = .FALSE.

C     Initialize conc field: Copy IC's to CONC file as step 0.
C     Convention: the input file concentration units are always ppmV

      CALL INITSCEN ( CGRID, ADJ_STDATE, ADJ_STTIME, TSTEP, ADJ_NSTEPS )

C     Calculate number of output time steps for the total simulation,
C     including all restarts

      STEPSECS = TIME2SEC(TSTEP(1))

      IF (MOD(ADJ_TOTSEC, STEPSECS) .EQ. 0) THEN
         ADJ_TOTSTEPS = ADJ_TOTSEC / STEPSECS
      ELSE
         MSG = "Output time step " // HHMMSS(TSTEP( 1 )) //
     &         " does not divide total duration " // HHMMSS(ADJ_TOTLEN)
         CALL M3EXIT( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2 )
      END IF

C     Verify input file header consistency with COORD.EXT and run
C     duration (excluding CHK files)

      CALL BARRIER(ADJ_STDATE, ADJ_STTIME)
      CALL FLCHECK ( ADJ_STDATE, ADJ_STTIME, TSTEP(1) )

C     Allocate ASTEP. Note (Lucas A. J. Bastien): NLAYS seems to be
C     known at that point. I am not sure where from.

      ALLOCATE ( ASTEP( NLAYS ), STAT = STATUS )
      IF ( STATUS .NE. 0 ) THEN
         MSG = 'ADJ_ASTEP memory allocation failed'
         CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2 )
      END IF

C     If running the forward loop and it is not a restart run, then
C     calculate minimum advection time step and sync time step, and
C     write the results to a text file. Otherwise, read these values
C     from the corresponding text file.

      IF (RTO_FWD .AND. (.NOT. RTO_FWD_RST)) THEN

         CALL ADVSTEPMIN(NLAYS, ADJ_TOTSTEPS, ADJ_STDATE_TOT,
     &                   ADJ_STTIME_TOT, TSTEP, ASTEP, NREPS)

         IF (MYPE .EQ. 0) THEN
            CALL WR_ADVSTEPMIN(NLAYS, TSTEP, ASTEP, NREPS)
         END IF

      ELSE

         CALL RD_ADVSTEPMIN(NLAYS, TSTEP, ASTEP, NREPS)

      END IF

C     Number of CHK time steps per ACONC time step

      IF (RTO_FWD) THEN

         IF (TSTEP_ACONC .EQ. 0) THEN
            MSG = "Bad value (0) for TSTEP_ACONC."
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         ELSE IF (TSTEP_ACONC .GT. 0) THEN
            STEPSECS = TIME2SEC(TSTEP(2))
            IF (MOD(TIME2SEC(TSTEP_ACONC), STEPSECS) .NE. 0) THEN
               MSG = "CHK time step " // HHMMSS(TSTEP(2)) //
     &              " does not divide ACONC time step " //
     &              HHMMSS(TSTEP_ACONC)
               CALL M3EXIT(PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2)
            END IF
            N_CHK_ACONC = TIME2SEC(TSTEP_ACONC) / STEPSECS
            WRITE (LOGDEV, '(5X, A, 1X, I8)') "Number of CHK time " //
     &           "steps per ACONC time step:", N_CHK_ACONC
         ELSE
            WRITE (LOGDEV, '(5X, A)') "No ACONC file requested."
         END IF

      END IF

C     Number of CHK time steps per AL5CHK time step

      IF (RTO_BWD) THEN

         IF (TSTEP_AL5CHK .EQ. 0) THEN
            MSG = "Bad value (0) for TSTEP_AL5CHK."
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         ELSE IF (TSTEP_AL5CHK .GT. 0) THEN
            STEPSECS = TIME2SEC(TSTEP(2))
            IF (MOD(TIME2SEC(TSTEP_AL5CHK), STEPSECS) .NE. 0) THEN
               MSG = "CHK time step " // HHMMSS(TSTEP(2)) //
     &              " does not divide AL5CHK time step " //
     &              HHMMSS(TSTEP_AL5CHK)
               CALL M3EXIT(PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2)
            END IF
            N_CHK_AL5CHK = TIME2SEC(TSTEP_AL5CHK) / STEPSECS
            WRITE (LOGDEV, '(5X, A, 1X, I8)') "Number of CHK time " //
     &           "steps per AL5CHK time step:", N_CHK_AL5CHK
         ELSE
            WRITE (LOGDEV, '(5X, A)') "No AL5CHK file requested."
         END IF

      END IF

C     Create checkpoint files (Note that the time step in checkpoint
C     files is synchronization time step = TSTEP(2))

      CHKPROC = .TRUE.
      CALL OPCONC ( CGRID, ADJ_STDATE, ADJ_STTIME, TSTEP(2) )

C     Verify input file header consistency with COORD.EXT and run
C     duration (CHK files only)

      CALL BARRIER(ADJ_STDATE, ADJ_STTIME)
      CALL FLCHECK ( ADJ_STDATE, ADJ_STTIME, TSTEP( 2 ) )

C     Initialize process analysis if necessary

      IF ( LIPR .OR. LIRR ) CALL PA_INIT ( CGRID, ADJ_STDATE,
     &                                     ADJ_STTIME, TSTEP )

C     ============
C     FORWARD LOOP
C     ============

      CALL BARRIER(ADJ_STDATE, ADJ_STTIME)
      IF (RTO_FWD) THEN

C     Allocate array(s)

         IF (TSTEP_ACONC .GT. 0) THEN
            ALLOCATE(CGRID_AVG(MY_NCOLS,MY_NROWS,NLAYS,NSPCSD),
     &           STAT = STATUS)
            IF (STATUS .NE. 0) THEN
               MSG = "CGRID_AVG memory allocation failed"
               CALL M3EXIT (PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2)
            END IF
         END IF

C     Initialize

         LAST = .FALSE.

         JDATE = ADJ_STDATE
         JTIME = ADJ_STTIME

C     Initialize CGRID if it is a restart run (note that CGRID values
C     are initialized in INITSCEN except for the variable RHOJ. The
C     following call to RD_CHK is meant to initialize the RHOJ values in
C     CGRID)

         IF (RTO_FWD_RST .AND. RTO_CHK) THEN

C     We have to manually open CONC_CHK as read/write, otherwise it gets
C     opened as read-only by RD_CHK

            IF (.NOT. OPEN3(CONC_CHK, FSRDWR3, PNAME)) THEN
               MSG = "Could not open " // CONC_CHK //
     &              " file for update"
               CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT1)
            END IF

            CALL RD_CHK(CGRID, JDATE, JTIME)

         ELSE

C     Write CGRID to CONC_CHK for initial time step

            IF (RTO_CHK) CALL WR_CHK ( CGRID, JDATE, JTIME )

         END IF

C     Initialize CGRID_AVG if necessary

         IF (TSTEP_ACONC .GT. 0) THEN
            DO IC = 1, MY_NCOLS
               DO IR = 1, MY_NROWS
                  DO IL = 1, NLAYS
                     DO IN = 1, NSPCSD
                        CGRID_AVG(IC, IR, IL, IN)=CGRID(IC, IR, IL, IN)
                     END DO
                  END DO
               END DO
            END DO
            JDATE_AVG = JDATE
            JTIME_AVG = JTIME
            I_AVG = 1
         END IF

C     Main processing loop

         DO ISTEP = 1, ADJ_NSTEPS ! Output time step loop

            IF (MYPE .EQ. 0) THEN
               PRINT'(A, I5, A, I5)', "  Forward loop, ISTEP ", ISTEP,
     &              " out of ", ADJ_NSTEPS
               CALL FLUSH()
            END IF
            CALL WALLTIME(WALLTIME1)

C     Science process loop

            DO IREP = 1, NREPS - 1

               CALL SCIPROC ( CGRID, JDATE, JTIME, TSTEP, ASTEP, LAST )

               IF (RTO_CHK) CALL WR_CHK ( CGRID, JDATE, JTIME )

               IF (TSTEP_ACONC .GT. 0) THEN

                  DO IC = 1, MY_NCOLS
                     DO IR = 1, MY_NROWS
                        DO IL = 1, NLAYS
                           DO IN = 1, NSPCSD
                              CGRID_AVG(IC, IR, IL, IN) =
     &                             CGRID_AVG(IC, IR, IL, IN) +
     &                             CGRID(IC, IR, IL, IN)
                           END DO
                        END DO
                     END DO
                  END DO

                  I_AVG = I_AVG + 1

                  IF (I_AVG .EQ. N_CHK_ACONC) THEN
                     DO IC = 1, MY_NCOLS
                        DO IR = 1, MY_NROWS
                           DO IL = 1, NLAYS
                              DO IN = 1, NSPCSD
                                 CGRID_AVG(IC, IR, IL, IN) =
     &                                CGRID_AVG(IC, IR, IL, IN) /
     &                                FLOAT(N_CHK_ACONC)
                              END DO
                           END DO
                        END DO
                     END DO
                     CALL WR_ACONC(CGRID_AVG, JDATE_AVG, JTIME_AVG)
                     CGRID_AVG = 0.
                     I_AVG = 0
                     CALL NEXTIME(JDATE_AVG, JTIME_AVG, TSTEP_ACONC)
                  END IF

               END IF

            END DO

            LAST = (ISTEP .EQ. ADJ_NSTEPS)

            CALL SCIPROC ( CGRID, JDATE, JTIME, TSTEP, ASTEP, LAST )

            IF (RTO_CHK) CALL WR_CHK ( CGRID, JDATE, JTIME )

            CALL WR_CONC ( CGRID, JDATE, JTIME )

            IF (TSTEP_ACONC .GT. 0) THEN

               DO IC = 1, MY_NCOLS
                  DO IR = 1, MY_NROWS
                     DO IL = 1, NLAYS
                        DO IN = 1, NSPCSD
                           CGRID_AVG(IC, IR, IL, IN) =
     &                          CGRID_AVG(IC, IR, IL, IN) +
     &                          CGRID(IC, IR, IL, IN)
                        END DO
                     END DO
                  END DO
               END DO

               I_AVG = I_AVG + 1

               IF (I_AVG .EQ. N_CHK_ACONC) THEN
                  DO IC = 1, MY_NCOLS
                     DO IR = 1, MY_NROWS
                        DO IL = 1, NLAYS
                           DO IN = 1, NSPCSD
                              CGRID_AVG(IC, IR, IL, IN) =
     &                             CGRID_AVG(IC, IR, IL, IN) /
     &                             FLOAT(N_CHK_ACONC)
                           END DO
                        END DO
                     END DO
                  END DO
                  CALL WR_ACONC(CGRID_AVG, JDATE, JTIME)
                  CGRID_AVG = 0.
                  I_AVG = 0
                  CALL NEXTIME(JDATE_AVG, JTIME_AVG, TSTEP_ACONC)
               END IF

            END IF

            IF ( LIPR .OR. LIRR ) CALL PA_OUTPUT ( CGRID, JDATE, JTIME )

            CALL WALLTIME(WALLTIME2)
            WRITE(LOGDEV, '(A, I5, A, I5, A, E12.6)')
     &           "Walltime for forward step ", ISTEP,
     &           " (out of ", ADJ_NSTEPS, "): ", WALLTIME2-WALLTIME1

         END DO ! ISTEP (Output time step loop, forward)

C     Deallocate array(s)

         IF (TSTEP_ACONC .GT. 0) THEN
            DEALLOCATE (CGRID_AVG, STAT=STATUS)
            IF (STATUS .NE. 0) THEN
               MSG = "CGRID_AVG memory deallocation failed"
               CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
            END IF
         END IF

      END IF ! RTO_FWD (i.e. do forward loop)

C     =============
C     BACKWARD LOOP
C     =============

      CALL BARRIER(ADJ_STDATE, ADJ_STTIME)
      IF (RTO_BWD) THEN

C     Switch status of some files to read-only

         IF ( .NOT. OPEN3( CTM_CONC_1, FSREAD3, PNAME ) ) THEN
            MSG = "Could not open " // CTM_CONC_1 // " file for reading"
            CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2 )
         END IF

         IF ( .NOT. OPEN3( CONC_CHK, FSREAD3, PNAME ) ) THEN
            MSG = "Could not open " // CONC_CHK // " file for reading"
            CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2 )
         END IF

         IF ( .NOT. OPEN3( CONC_L4CHK, FSREAD3, PNAME ) ) THEN
            MSG = "Could not open " // CONC_L4CHK // " file for reading"
            CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2 )
         END IF

      CALL BARRIER(ADJ_STDATE, ADJ_STTIME)

C     Allocate array(s)

         ALLOCATE ( LGRID( MY_NCOLS,MY_NROWS,NLAYS,NSPCSD ),
     &        STAT = STATUS )
         IF ( STATUS .NE. 0 ) THEN
            MSG = "LGRID memory allocation failed"
            CALL M3EXIT ( PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2 )
         END IF

         IF (TSTEP_AL5CHK .GT. 0) THEN
            ALLOCATE(LGRID_AVG(MY_NCOLS,MY_NROWS,NLAYS,NSPCSD),
     &           STAT = STATUS)
            IF (STATUS .NE. 0) THEN
               MSG = "LGRID_AVG memory allocation failed"
               CALL M3EXIT (PNAME, ADJ_STDATE, ADJ_STTIME, MSG, XSTAT2)
            END IF
         END IF

      CALL BARRIER(ADJ_STDATE, ADJ_STTIME)

C     Initialize

         JDATE = ADJ_STDATE
         JTIME = ADJ_STTIME
         CALL NEXTIME ( JDATE, JTIME, ADJ_RUNLEN )

         IF (RTO_BWD_RST .AND. (.NOT. L5FCHK_READ)) THEN

C     We have to manually open CONC_L5CHK as read/write, otherwise it
C     gets opened as read-only by RD_L5CHK

            IF (.NOT. OPEN3(CONC_L5CHK, FSRDWR3, PNAME)) THEN
               MSG = "Could not open " // CONC_L5CHK //
     &              " file for update"
               CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT1)
            END IF

            CALL RD_L5CHK(LGRID, JDATE, JTIME)

         ELSE IF (L5FCHK_READ .AND. (.NOT. RTO_BWD_RST)) THEN

            CALL RD_L5FCHK(LGRID, JDATE, JTIME)

         ELSE IF ((.NOT. RTO_BWD_RST) .AND. (.NOT. L5FCHK_READ)) THEN

            LGRID = 0.0

         ELSE

            MSG = "Incompatible adjoint variable initialization options"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)

         END IF

         IF (TSTEP_AL5CHK .GT. 0) THEN
            LGRID_AVG = 0.0
            I_AVG = 0
         END IF

         RESDATE = JDATE
         RESTIME = JTIME

C     Main processing loop

         DO ISTEP = ADJ_NSTEPS, 1, -1 ! output time step loop

            IF (MYPE .EQ. 0) THEN
               PRINT'(A, I5, A, I5)', "  Backward loop, ISTEP ",
     &              ADJ_NSTEPS-ISTEP+1, " out of ", ADJ_NSTEPS
               CALL FLUSH()
            END IF
            CALL WALLTIME(WALLTIME1)

            SDATE = JDATE
            STIME = JTIME

            CALL NEXTIME ( SDATE, STIME, -TSTEP(1) )

C     Reverse science process sequence

            DO IREP = NREPS, 1, -1

               CALL NEXTIME ( RESDATE, RESTIME, -TSTEP(2) )

               IF ((.NOT. RTO_BWD_RST) .AND. (.NOT. L5FCHK_READ) .AND.
     &             (ISTEP .EQ. ADJ_NSTEPS) .AND. (IREP .EQ. NREPS)) THEN

C     In a non restart run, we skip the very first step that is
C     calculated (i.e. the very last step) so that the integral time of
C     the simulation is exactly the desired length. See notes of March
C     10 2014 for more details. So we just remove one synchronization
C     time step from JDATE, JTIME, because that is what is done in
C     SCIPROC_ADJ, and record that as the final time step

                  CALL NEXTIME ( JDATE, JTIME, -TSTEP( 2 ) )

               ELSE

                  CALL RD_CHK ( CGRID, RESDATE, RESTIME )

                  LAST = ((ISTEP .EQ. 1) .AND. (IREP .EQ. 1))

                  CALL SCIPROC_ADJ ( LGRID, JDATE, JTIME, TSTEP, ASTEP,
     &                               LAST )

               END IF

               IF (RTO_CHK) THEN
                  CALL WR_L5CHK ( LGRID, JDATE, JTIME )
               END IF

               IF (L5FCHK_WRITE .AND. (L5FCHK_DATE .EQ. JDATE)
     &                          .AND. (L5FCHK_TIME .EQ. JTIME)) THEN
                  CALL WR_L5FCHK(LGRID, JDATE, JTIME)
               END IF

               IF (TSTEP_AL5CHK .GT. 0) THEN

                  DO IC = 1, MY_NCOLS
                     DO IR = 1, MY_NROWS
                        DO IL = 1, NLAYS
                           DO IN = 1, NSPCSD
                              LGRID_AVG(IC, IR, IL, IN) =
     &                             LGRID_AVG(IC, IR, IL, IN) +
     &                             LGRID(IC, IR, IL, IN)
                           END DO
                        END DO
                     END DO
                  END DO

                  I_AVG = I_AVG + 1

                  IF (I_AVG .EQ. N_CHK_AL5CHK) THEN
                     DO IC = 1, MY_NCOLS
                        DO IR = 1, MY_NROWS
                           DO IL = 1, NLAYS
                              DO IN = 1, NSPCSD
                                 LGRID_AVG(IC, IR, IL, IN) =
     &                                LGRID_AVG(IC, IR, IL, IN) /
     &                                FLOAT(N_CHK_AL5CHK)
                              END DO
                           END DO
                        END DO
                     END DO
                     CALL WR_AL5CHK(LGRID_AVG, JDATE, JTIME)
                     LGRID_AVG = 0.
                     I_AVG = 0
                  END IF

               END IF

            END DO

            CALL WALLTIME(WALLTIME2)
            WRITE(LOGDEV, '(A, I5, A, I5, A, E12.6)')
     &           "Walltime for backward step ", ADJ_NSTEPS-ISTEP+1,
     &           " (out of ", ADJ_NSTEPS, "): ", WALLTIME2-WALLTIME1

         END DO ! ISTEP (backward loop)

C     Finalize

         DEALLOCATE(LGRID, STAT = STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = 'LGRID memory deallocation failed'
            CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

         IF (TSTEP_AL5CHK .GT. 0) THEN
            DEALLOCATE (LGRID_AVG, STAT=STATUS)
            IF (STATUS .NE. 0) THEN
               MSG = 'LGRID_AVG memory deallocation failed'
               CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
            END IF
         END IF

      END IF ! RTO_BWD (i.e. do backward loop)

C     ========
C     FINALIZE
C     ========

C     Deallocate array(s)

      DEALLOCATE ( ASTEP, STAT = STATUS )
      IF ( STATUS .NE. 0 ) THEN
         MSG = 'ASTEP memory deallocation failed'
         CALL M3EXIT ( PNAME, JDATE, JTIME, MSG, XSTAT2 )
      END IF

C     Close files

      IF ( .NOT. CLOSE3( CTM_CONC_1 ) ) THEN
         MSG = 'Could not close ' // CTM_CONC_1
         CALL M3WARN( PNAME, JDATE, JTIME, MSG )
      END IF

      IF ( .NOT. CLOSE3( CONC_CHK ) ) THEN
         MSG = 'Could not close ' // CONC_CHK
         CALL M3WARN( PNAME, JDATE, JTIME, MSG )
      END IF

      IF ( .NOT. CLOSE3( CONC_L2CHK ) ) THEN
         MSG = 'Could not close ' // CONC_L2CHK
         CALL M3WARN( PNAME, JDATE, JTIME, MSG )
      END IF

      IF ( .NOT. CLOSE3( CONC_L4CHK ) ) THEN
         MSG = 'Could not close ' // CONC_L4CHK
         CALL M3WARN( PNAME, JDATE, JTIME, MSG )
      END IF

      IF ( .NOT. CLOSE3( CONC_L5CHK ) ) THEN
         MSG = 'Could not close ' // CONC_L5CHK
         CALL M3WARN( PNAME, JDATE, JTIME, MSG )
      END IF

      IF ( .NOT. CLOSE3( FIL_REC ) ) THEN
         MSG = 'Could not close ' // FIL_REC
         CALL M3WARN( PNAME, JDATE, JTIME, MSG )
      END IF

      IF ( .NOT. CLOSE3( CONC_AL5CHK ) ) THEN
         MSG = 'Could not close ' // CONC_AL5CHK
         CALL M3WARN( PNAME, JDATE, JTIME, MSG )
      END IF

      IF ( .NOT. CLOSE3( A_CONC_1 ) ) THEN
         MSG = 'Could not close ' // A_CONC_1
         CALL M3WARN( PNAME, JDATE, JTIME, MSG )
      END IF

      IF ( .NOT. CLOSE3( CONC_L5FCHK_R ) ) THEN
         MSG = 'Could not close ' // CONC_L5FCHK_R
         CALL M3WARN( PNAME, JDATE, JTIME, MSG )
      END IF

      IF ( .NOT. CLOSE3( CONC_L5FCHK_W ) ) THEN
         MSG = 'Could not close ' // CONC_L5FCHK_W
         CALL M3WARN( PNAME, JDATE, JTIME, MSG )
      END IF

C     Clean up communications (Should be end times rather than start times)

      CALL PAR_TERM ( PNAME, JDATE, JTIME, CLOCK )

      END PROGRAM DRIVER
