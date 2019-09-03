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
C     Author: Lucas A. J. Bastien
C
C     This is a module that contains parameters for the adjoint of
C     CMAQ-v4.5-ADJ.

      MODULE ADJPRM

      IMPLICIT NONE

C     RTO_* variables are run-time options. RTO stands for run-time
C     option

      LOGICAL, SAVE :: RTO_FWD     ! Do forward loop
      LOGICAL, SAVE :: RTO_FWD_RST ! Forward restart flag
      LOGICAL, SAVE :: RTO_BWD     ! Do backward loop
      LOGICAL, SAVE :: RTO_BWD_RST ! Backward restart flag
      LOGICAL, SAVE :: RTO_CHK     ! Whether to checkpoint or not

C     Start date and time of the simulation

      INTEGER, SAVE :: ADJ_STDATE
      INTEGER, SAVE :: ADJ_STTIME

C     Start date and time of the full simulation, including restarts

      INTEGER, SAVE :: ADJ_STDATE_TOT
      INTEGER, SAVE :: ADJ_STTIME_TOT

C     ADJ_RUNLEN is the length of the simulation. ADJ_TOTLEN is the
C     length of the simulation including future planned restart runs
C     (defaults to ADJ_RUNLEN if not found in the
C     environment). ADJ_TOTSEC is ADJ_TOTLEN in seconds

      INTEGER, SAVE :: ADJ_RUNLEN
      INTEGER, SAVE :: ADJ_TOTLEN
      INTEGER, SAVE :: ADJ_TOTSEC

C     ADJ_NSTEPS is the number of output time steps for the
C     simulation. ADJ_TOTSTEPS is the number of output time steps for
C     the total simulation, including future restarts

      INTEGER, SAVE :: ADJ_NSTEPS
      INTEGER, SAVE :: ADJ_TOTSTEPS

C     REC_SPECIES is the name of the species for which the receptor is
C     defined. REC_VAR contains the name of the variable corresponding
C     to the receptor in the receptor input file

      CHARACTER(16), SAVE :: REC_SPECIES
      CHARACTER(16), SAVE :: REC_VAR

C     Units of the output adjoint variables, which depend on the units
C     of the receptor variable

      CHARACTER(16), SAVE :: ADJ_UNITS = ""

C     Some functions/subroutines need to know whether to process
C     checkpoint files. CHKPROC is the switch for that

      LOGICAL, SAVE :: CHKPROC

C     Path of text file where results from ADVSTEP_MIN are recorded

      CHARACTER(500) :: FIL_ASTEP

C     Parameters for the ACONC file

      INTEGER, SAVE :: TSTEP_ACONC ! Time step for ACONC file
      INTEGER, SAVE :: N_CHK_ACONC ! Number of CHK time steps per
                                   ! ACONC time step

C     Parameters for the AL5CHK file

      INTEGER, SAVE :: TSTEP_AL5CHK ! Time step for AL5CHK file
      INTEGER, SAVE :: N_CHK_AL5CHK ! Number of CHK time steps per
                                    ! AL5CHK time step

C     Whether to start with x or y advection in SCIPROC and SCIPROC_ADJ
C     (respectively) at the first iteration of the loop

      LOGICAL, SAVE :: XFIRST_FWD
      LOGICAL, SAVE :: XFIRST_BWD

C     Variables that control flash checkpointing of the adjoint variable

      LOGICAL, SAVE :: L5FCHK_READ  ! Whether to read L5FCHK or not
      LOGICAL, SAVE :: L5FCHK_WRITE ! Whether to write L5FCHK or not
      INTEGER, SAVE :: L5FCHK_DATE  ! Date for L5FCHK writing
      INTEGER, SAVE :: L5FCHK_TIME  ! Time for L5FCHK writing

C     ==================================================================

      CONTAINS

C     ==================================================================

      SUBROUTINE READ_ADJPRM ()

C     PURPOSE:
C     Reads the values of the RTO_* and REC_* options from the
C     environment.

      IMPLICIT NONE

C     Include files

      INCLUDE SUBST_IOPARMS ! I/O parameters definitions
      INCLUDE SUBST_IODECL  ! I/O definitions and declarations

C     Local variables

      CHARACTER(16) :: PNAME   ! Program name
      LOGICAL, SAVE :: FIRSTIME = .TRUE. ! Is it the first time running
                                         ! this subroutine?
      INTEGER, SAVE :: LOGDEV            ! Logical unit of log file
      INTEGER       :: JDATE   ! Current date, format YYYYDDD
      INTEGER       :: JTIME   ! Current time, format HHMMSS
      INTEGER       :: STATUS  ! Status when reading environment
      CHARACTER(80) :: VARDESC ! environment variable description
      CHARACTER(80) :: MSG     ! Status/warning/error Message

C     External functions

      LOGICAL, EXTERNAL :: ENVYN    ! Read logical environment variables
      INTEGER, EXTERNAL :: ENVINT   ! Read integer environment variables
      INTEGER, EXTERNAL :: TIME2SEC ! Converts HHMMSS to raw seconds

C     ------------------------------------------------------------------

      PNAME = "READ_RTOPT"
      JDATE = -9999
      JTIME = -9999

C     This subroutine should be run only once

      IF ( .NOT. FIRSTIME ) THEN
         MSG = "READ_RTOPT called more than once"
         CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
      END IF

      FIRSTIME = .FALSE.
      LOGDEV = INIT3 ()

C     Prepare the outputing to log file

      WRITE( LOGDEV, '(A)' ) ""
      WRITE( LOGDEV, '(5X, A)' ) "Reading runtime options ..."

C     --- RTO_FWD ---

      VARDESC = "Run forward loop?"
      RTO_FWD = ENVYN( "RTO_FWD", VARDESC, .TRUE., STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .FALSE.
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .FALSE.
         END IF
      END IF

C     --- RTO_FWD_RST ---

      VARDESC = "Restart forward run?"
      RTO_FWD_RST = ENVYN( "RTO_FWD_RST", VARDESC, .FALSE., STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .FALSE.
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .FALSE.
         END IF
      END IF

C     --- RTO_BWD ---

      VARDESC = "Run backward loop?"
      RTO_BWD = ENVYN( "RTO_BWD", VARDESC, .FALSE., STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .FALSE.
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .FALSE.
         END IF
      END IF

C     --- RTO_BWD_RST ---

      VARDESC = "Restart backward run?"
      RTO_BWD_RST = ENVYN( "RTO_BWD_RST", VARDESC, .FALSE., STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .FALSE.
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .FALSE.
         END IF
      END IF

C     --- RTO_CHK ---

      VARDESC = "Checkpoint?"
      RTO_CHK = ENVYN( "RTO_CHK", VARDESC, .TRUE., STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .TRUE.
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .TRUE.
         END IF
      END IF

C     --- ADJ_RUNLEN ---

      VARDESC = "Simulation length"
      ADJ_RUNLEN = ENVINT( "CTM_RUNLEN", VARDESC, 480000, STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, 480000
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, 480000
         END IF
      END IF

C     --- ADJ_TOTLEN ---

      VARDESC = "Simulation length including future restarts"
      ADJ_TOTLEN = ENVINT( "ADJ_TOTLEN", VARDESC, ADJ_RUNLEN, STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, ADJ_RUNLEN
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, ADJ_RUNLEN
         END IF
      END IF

C     --- ADJ_STDATE_TOT ---

      VARDESC = "Full simulation start date, including restarts"
      ADJ_STDATE_TOT = ENVINT( "ADJ_STDATE_TOT", VARDESC, 0, STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, 0
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, 0
         END IF
      END IF

C     --- ADJ_STTIME_TOT ---

      VARDESC = "Full simulation start date, including restarts"
      ADJ_STTIME_TOT = ENVINT( "ADJ_STTIME_TOT", VARDESC, 0, STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, 0
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, 0
         END IF
      END IF

C     --- REC_SPECIES ---

      VARDESC = "Receptor: species"
      CALL ENVSTR( "REC_SPECIES", VARDESC, 'N/A', REC_SPECIES, STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, A)' ) MSG, "N/A"
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, A)' ) MSG, "N/A"
         END IF
      END IF

C     --- REC_VAR ---

      VARDESC = "Receptor: variable name"
      CALL ENVSTR( "REC_VAR", VARDESC, 'N/A', REC_VAR, STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, A)' ) MSG, "N/A"
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, A)' ) MSG, "N/A"
         END IF
      END IF

C     --- FIL_ASTEP ---

      VARDESC = "ADVTSTEP_MIN results file"
      CALL ENVSTR( "FIL_ASTEP", VARDESC, 'N/A', FIL_ASTEP, STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, A)' ) MSG, "N/A"
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, A)' ) MSG, "N/A"
         END IF
      END IF

C     --- TSTEP_AL5CHK ---

      VARDESC = "Time step for AL5CHK file (format HHMMSS)"
      TSTEP_AL5CHK = ENVINT( "TSTEP_AL5CHK", VARDESC, -1, STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, -1
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, -1
         END IF
      END IF

C     --- TSTEP_ACONC ---

      VARDESC = "Time step for ACONC file (format HHMMSS)"
      TSTEP_ACONC = ENVINT( "TSTEP_ACONC", VARDESC, -1, STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, -1
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, -1
         END IF
      END IF

C     --- XFIRST_FWD ---

      VARDESC = "Run backward loop?"
      XFIRST_FWD = ENVYN( "XFIRST_FWD", VARDESC, .TRUE., STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .TRUE.
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .TRUE.
         END IF
      END IF

C     --- XFIRST_BWD ---

      VARDESC = "Run backward loop?"
      XFIRST_BWD = ENVYN( "XFIRST_BWD", VARDESC, .TRUE., STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .TRUE.
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .TRUE.
         END IF
      END IF

C     --- L5FCHK_READ ---

      VARDESC = "Read L5FCHK?"
      L5FCHK_READ = ENVYN( "L5FCHK_READ", VARDESC, .FALSE., STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .FALSE.
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .FALSE.
         END IF
      END IF

C     --- L5FCHK_WRITE ---

      VARDESC = "Write L5FCHK?"
      L5FCHK_WRITE = ENVYN( "L5FCHK_WRITE", VARDESC, .FALSE., STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .FALSE.
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, L1)' ) MSG, .FALSE.
         END IF
      END IF

C     --- L5FCHK_DATE ---

      VARDESC = "Date for L5FCHK writing (format YYYYDDD)"
      L5FCHK_DATE = ENVINT( "L5FCHK_DATE", VARDESC, -1, STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, -1
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, -1
         END IF
      END IF

C     --- L5FCHK_TIME ---

      VARDESC = "Time for L5CHK writing (format HHMMSS)"
      L5FCHK_TIME = ENVINT( "L5FCHK_TIME", VARDESC, -1, STATUS )
      IF ( STATUS .NE. 0 ) THEN
         WRITE( LOGDEV, '(5X, A)' ) VARDESC
         IF ( STATUS .EQ. 1 ) THEN
            MSG = "Environment variable improperly formatted"
            CALL M3EXIT( PNAME, JDATE, JTIME, MSG, XSTAT2 )
         ELSE IF ( STATUS .EQ. -1 ) THEN
            MSG = "Environment variable set but empty Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, -1
         ELSE IF ( STATUS .EQ. -2 ) THEN
            MSG = "Environment variable not set ... Using default:"
            WRITE( LOGDEV, '(5X, A, I6)' ) MSG, -1
         END IF
      END IF

C     Some options are mutually exclusive

      IF (RTO_FWD .AND. RTO_BWD .AND. (.NOT. RTO_CHK)) THEN
         MSG = "Need to checkpoint to run the backward loop"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

      IF ((.NOT. RTO_FWD) .AND. (.NOT. RTO_BWD)) THEN
         MSG = "Need to run at least one of the loops"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

      IF (RTO_FWD_RST .AND. (.NOT. RTO_FWD)) THEN
         MSG = "Need to activate forward if running restart forward"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

      IF (RTO_FWD_RST .AND. RTO_BWD) THEN
         MSG = "Forward restart excludes backward loop"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

      IF (RTO_BWD_RST .AND. (.NOT. RTO_BWD)) THEN
         MSG = "Need to activate backward if running restart backward"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

      IF (RTO_BWD_RST .AND. RTO_FWD) THEN
         MSG = "Backward restart excludes forward loop"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

      IF (L5FCHK_READ .AND. (.NOT. RTO_BWD)) THEN
         MSG = "Need to activate backward to read L5FCHK"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

      IF (L5FCHK_WRITE .AND. (.NOT. RTO_BWD)) THEN
         MSG = "Need to activate backward to write L5FCHK"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

      IF (L5FCHK_READ .AND. RTO_BWD_RST) THEN
         MSG = "Cannot read L5FCHK during a restared run"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

C     Derived quantities

      IF (RTO_BWD .AND. (.NOT. RTO_BWD_RST)) THEN
         CALL GET_ADJ_UNITS(ADJ_UNITS)
      END IF

C     The following "if-then-else" structure is there to prevent
C     overflow errors when ADJ_TOTLEN is too large

      IF (ADJ_TOTLEN .LT. 1000000) THEN
         ADJ_TOTSEC = TIME2SEC(ADJ_TOTLEN)
      ELSE
         ADJ_TOTSEC = TIME2SEC(ADJ_TOTLEN - 1000000) + 360000
      END IF

C     We are done here

      RETURN

      END SUBROUTINE READ_ADJPRM

C     ==================================================================

      SUBROUTINE GET_ADJ_UNITS(UNITS)

C     PURPOSE:
C
C     Determine the units of the output adjoint variables. The units of
C     the output adjoint variables (lambda*) are u*s where u is the
C     units of the adjoint forcing term (\partial g / \partial C*).
C
C     *: using the notations of Hakami et al. "The Adjoint of CMAQ",
C        Environmental Science and Technology 2007, 41, 7807-7817. DOI:
C        10.1021/es070944p.

      IMPLICIT NONE

C     Include files

      INCLUDE SUBST_IOPARMS  ! I/O parameters definitions
      INCLUDE SUBST_IOFDESC  ! File description
      INCLUDE SUBST_IODECL   ! I/O definitions and declarations
      INCLUDE SUBST_FILES_ID ! Files logical names

C     Argument(s)

      CHARACTER(16), INTENT(OUT) :: UNITS

C     Local variables

      CHARACTER(16) :: PNAME
      CHARACTER(80) :: MSG
      INTEGER :: JDATE, JTIME, ISPC, L

C     External function(s)

      INTEGER, EXTERNAL :: INDEX1   ! Find index of species in list

C     ------------------------------------------------------------------

      PNAME = "GET_ADJ_UNITS"
      JDATE = -9999
      JTIME = -9999

C     Get units of the adjoint forcing term

      IF (.NOT. OPEN3(FIL_REC, FSREAD3, PNAME)) THEN
         MSG = "Could not open " // FIL_REC // " file for reading"
         CALL M3EXIT ( PNAME, JDATE, JTIME, MSG, XSTAT1 )
      END IF

      IF (.NOT. DESC3(FIL_REC)) THEN
         MSG = "Could not get "// FIL_REC // " file description"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

      ISPC = INDEX1(REC_VAR, NVARS3D, VNAME3D)
      UNITS = UNITS3D(ISPC)

C     Multiply these units by seconds. In some cases the output units
C     are not formatted as nicely as they could. For example, if the
C     units of the forcing term are s**2/m, this subroutine will output
C     s**2/m*s instead of s**3/m. However, fixing this is low priority
C     for me at this point. TODO: format output units nicely in all
C     cases

      L = LEN_TRIM(UNITS)
      IF ((UNITS(L-1:L) .EQ. "/s") .OR. (UNITS(L-1:L) .EQ. "/S")) THEN
         UNITS = UNITS(1:L-2)
      ELSE IF (UNITS(1:2) .EQ. "1/") THEN
         UNITS = "s" // UNITS(2:L)
      ELSE IF (L > 14) THEN
         MSG = "Forcing term units too long: " // TRIM(UNITS)
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      ELSE
         UNITS = TRIM(UNITS) // "*s"
      END IF

      END SUBROUTINE GET_ADJ_UNITS

C     ==================================================================

      END MODULE ADJPRM
