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
C     Author: Lucas A. J. Bastien.
C
C     This file is part of the CMAQ-v4.5-ADJ post processor adjpost.
C
C     This file is the module that contains most resources for adjpost.

      MODULE ADJPOST_MODULE

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IOPARMS

C     --- Local variables

C     Lengths of character strings

      INTEGER, PARAMETER :: LEN_PNAME = 16,
     &                      LEN_MSG = 80,
     &                      LEN_GRIDNAME = 16,
     &                      LEN_LOGICAL_NAME = 16,
     &                      LEN_NICKNAME = 16,
     &                      LEN_FILE_CAT = 4,
     &                      LEN_SENS_TYPE = 2,
     &                      LEN_SENS_TYPE_LONG = 20,
     &                      LEN_PERT_TYPE = 3,
     &                      LEN_VNAME = 16,
     &                      LEN_UNITS = 16,
     &                      LEN_TREATMENT = 5,
     &                      LEN_BDY = 1

C     Sizes of fixed-size arrays

      INTEGER, PARAMETER :: N_SENS_TYPES = 3,
     &                      N_FILE_CATS = 4

C     Other integer parameters

      INTEGER, PARAMETER :: JDATE_NONE = 0, JTIME_NONE = 0

C     Physical constants and unit conversion constants

      REAL, PARAMETER :: CONST_R = 8.314,
     &                   CONST_PPMV2FRAC = 1.0E-6

C     List of supported sensitivity types

      CHARACTER(LEN=LEN_SENS_TYPE), PARAMETER ::
     &    SENSITIVITY_TYPES(N_SENS_TYPES) = (/"BC", "IC", "EM"/)

      CHARACTER(LEN=LEN_SENS_TYPE_LONG) :: SENSITIVITY_TYPES_LONG(N_SENS_TYPES)

C     Variables that contain run-time user-defined options or quantities
C     derived from these user options

      INTEGER, SAVE :: N_INFILES(N_SENS_TYPES), N_SPECIES(N_SENS_TYPES),
     &                 N_SPCCATS(N_SENS_TYPES), N_TREATMENTS(N_SENS_TYPES),
     &                 N_DISTINCT_SPCCATS, N_TSTEPS

      CHARACTER(LEN=LEN_GRIDNAME), SAVE :: GRIDNAME
      CHARACTER(LEN=LEN_LOGICAL_NAME), ALLOCATABLE, SAVE :: INFILES(:,:)
      CHARACTER(LEN=LEN_NICKNAME), ALLOCATABLE, SAVE :: NICKNAMES(:,:)
      CHARACTER(LEN=LEN_TREATMENT), ALLOCATABLE, SAVE :: TREATMENTS(:,:)
      CHARACTER(LEN=LEN_VNAME), ALLOCATABLE, SAVE :: SPECIES(:,:),
     &                                               SPCCATS(:),
     &                                               SPCSINCAT(:,:)

      INTEGER, ALLOCATABLE, SAVE :: N_SPCSINCAT(:)

C     Variables related to file descriptions

      INTEGER, SAVE :: NCOLS(N_FILE_CATS), NROWS(N_FILE_CATS),
     &                 NTHIK(N_FILE_CATS), GDTYP(N_FILE_CATS),
     &                 VGTYP(N_FILE_CATS), FTYPE(N_FILE_CATS),
     &                 NLAYS(N_FILE_CATS), SDATE, STIME, TSTEP

      REAL(KIND=8), SAVE :: P_ALP(N_FILE_CATS), P_BET(N_FILE_CATS),
     &                      P_GAM(N_FILE_CATS), XCENT(N_FILE_CATS),
     &                      YCENT(N_FILE_CATS), XORIG(N_FILE_CATS),
     &                      YORIG(N_FILE_CATS), XCELL(N_FILE_CATS),
     &                      YCELL(N_FILE_CATS)

      REAL, SAVE :: VGTOP(N_FILE_CATS), VGLVS(N_FILE_CATS, MXLAYS3+1)

      LOGICAL, SAVE ::
     &    FILE_CAT_FIRST(N_FILE_CATS) = (/.TRUE., .TRUE., .TRUE., .TRUE./)

C     Variables that contain physical quantities

      REAL, ALLOCATABLE, SAVE :: DZ_GRID(:,:,:), DZ_BDY(:,:,:),
     &                           PRES_GRID(:,:,:), PRES_BDY(:,:,:),
     &                           TA_GRID(:,:,:), TA_BDY(:,:,:),
     &                           INFLOW_BDY(:,:,:), WGT_SPCCAT(:,:,:,:),
     &                           BC_BDY(:,:,:), IC_GRID(:,:,:), EM_GRID(:,:,:),
     &                           ADJ_GRID(:,:,:), ADJ_BDY(:,:,:)

C     ==================================================================

      CONTAINS

C     ==================================================================

      SUBROUTINE INITIALIZE()

C     This subroutine initializes adjpost:
C      - Fills out SENSITIVITY_TYPES_LONG
C      - Reads run-time user-defined options.
C      - Checks input file.
C      - Creates output files.
C      - Creates resources to deal with species categories.
C      - Gets the number of time steps.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "INITIALIZE"
      CHARACTER(LEN=LEN_MSG) :: MSG
      CHARACTER(LEN=LEN_SENS_TYPE) :: ST
      CHARACTER(LEN=3) :: I_STR
      INTEGER :: LOG
      INTEGER :: STATUS, JDATE, JTIME,
     &           N_SPECIES_MAX, N_INFILES_MAX, N_TREATMENTS_MAX,
     &           I, I_ST

C     ---  External function

      LOGICAL :: RDTFLAG
      INTEGER :: NAME2FID

C     ------------------------------------------------------------------

      LOG = INIT3()

      N_SPECIES_MAX = 0
      N_INFILES_MAX = 0
      N_TREATMENTS_MAX = 0

C     Get the sizes of arrays that store user-defined options

      DO I_ST = 1, N_SENS_TYPES

         ST = SENSITIVITY_TYPES(I_ST)

         IF (ST .EQ. "BC") THEN
            SENSITIVITY_TYPES_LONG(I_ST) = "boundary conditions"
         ELSE IF (ST .EQ. "IC") THEN
            SENSITIVITY_TYPES_LONG(I_ST) = "initial conditions"
         ELSE IF (ST .EQ. "EM") THEN
            SENSITIVITY_TYPES_LONG(I_ST) = "emissions"
         ELSE
            MSG = "Unknown sensitivity type: " // ST
            CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
         END IF

         CALL GET_ENV_INT("N_SPECIES_" // ST,
     &                    "Number of species for " // ST // " sensitivity",
     &                    N_SPECIES(I_ST),
     &                    DEFAULT=0)

         CALL GET_ENV_INT("N_SPCCATS_" // ST,
     &                    "Number of categories for " // ST // " sensitivity",
     &                    N_SPCCATS(I_ST),
     &                    DEFAULT=0)

         IF (N_SPECIES(I_ST)+N_SPCCATS(I_ST) .GT. N_SPECIES_MAX) THEN
            N_SPECIES_MAX = N_SPECIES(I_ST)+N_SPCCATS(I_ST)
         END IF

         CALL GET_ENV_INT("N_INFILES_" // ST,
     &                    "Number of input " // ST // " files",
     &                    N_INFILES(I_ST),
     &                    DEFAULT=0)

         IF (N_INFILES(I_ST) .GT. N_INFILES_MAX) THEN
            N_INFILES_MAX = N_INFILES(I_ST)
         END IF

         CALL GET_ENV_INT("N_TREATMENTS_" // ST,
     &                    "Number of " // ST // " treatments",
     &                    N_TREATMENTS(I_ST),
     &                    DEFAULT=0)

         IF (N_TREATMENTS(I_ST) .GT. N_TREATMENTS_MAX) THEN
            N_TREATMENTS_MAX = N_TREATMENTS(I_ST)
         END IF

      END DO

C     Allocate arrays that store user-defined options

      ALLOCATE(INFILES(N_SENS_TYPES, N_INFILES_MAX), STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "INFILES memory allocation failed"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      ALLOCATE(NICKNAMES(N_SENS_TYPES, N_INFILES_MAX), STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "NICKNAMES memory allocation failed"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      ALLOCATE(SPECIES(N_SENS_TYPES, N_SPECIES_MAX), STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "SPECIES memory allocation failed"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      ALLOCATE(TREATMENTS(N_SENS_TYPES, N_TREATMENTS_MAX), STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "TREATMENTS memory allocation failed"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

C     Fill out arrays that store user-defined options

      DO I_ST = 1, N_SENS_TYPES

         ST = SENSITIVITY_TYPES(I_ST)

         DO I = 1, N_SPECIES(I_ST)
            WRITE(I_STR, '(I3.3)') I
            CALL GET_ENV_CHAR("SPECIES_" // ST // "_" // I_STR,
     &           "Name of variable SPECIES_" //ST // "_" // I_STR,
     &           SPECIES(I_ST, I))
         END DO

         DO I = 1, N_SPCCATS(I_ST)
            WRITE(I_STR, '(I3.3)') I
            CALL GET_ENV_CHAR("SPCCAT_" // ST // "_" // I_STR,
     &           "Name of variable SPCCAT_" //ST // "_" // I_STR,
     &           SPECIES(I_ST, N_SPECIES(I_ST)+I))
         END DO

         DO I = 1, N_INFILES(I_ST)
            WRITE(I_STR, '(I3.3)') I
            INFILES(I_ST, I) = "INFILE_" // ST // "_" // I_STR
            CALL GET_ENV_CHAR("NICKNAME_" // ST // "_" // I_STR,
     &                        "Nickname for INFILE_" //ST // "_" // I_STR,
     &                        NICKNAMES(I_ST, I))
         END DO

         DO I = 1, N_TREATMENTS(I_ST)
            WRITE(I_STR, '(I3.3)') I
            CALL GET_ENV_CHAR("TREATMENT_" // ST // "_" // I_STR,
     &           "Name of variable TREATMENT_" //ST // "_" // I_STR,
     &           TREATMENTS(I_ST, I))
         END DO

      END DO

C     Other initialization tasks

      CALL GET_ENV_CHAR("GRIDNAME", "Grid name", GRIDNAME, "No grid name")

      CALL CHECK_INPUTS()

C     Get the number of time steps

      JDATE = SDATE
      JTIME = STIME
      I = NAME2FID("INFILE_ADJ")
      DO WHILE (RDTFLAG(I, -1, JDATE, JTIME, N_TSTEPS, .TRUE.))
         CALL NEXTIME(JDATE, JTIME, TSTEP)
      END DO
      N_TSTEPS = N_TSTEPS - 1

      WRITE(LOG, '(/, 5X, A, I4, /)') "Number of time steps " //
     &                                "found in adjoint file: ", N_TSTEPS

      CALL CREATE_OUTPUTS()

      CALL INITIALIZE_CATS()

      END SUBROUTINE INITIALIZE

C     ==================================================================

      INTEGER FUNCTION COUNT_SPCCATS(FILL)

C     This function returns the number of distinct species categories
C     across all sensitivity types. If FILL is .TRUE. then the array
C     SPCCATS is filled out in the process (in which case the array
C     SPCCATS must be already allocated).

      IMPLICIT NONE

C     --- Arguments

      LOGICAL, INTENT(IN) :: FILL

C     ---  Local variables

      LOGICAL :: NEW_CAT
      INTEGER :: I_ST, I_ST2, I_SPC, I_SPC2, SPC2_LIM

C     ------------------------------------------------------------------

      COUNT_SPCCATS = 0

      DO I_ST = 1, N_SENS_TYPES
         IF (N_SPCCATS(I_ST) .GT. 0) THEN
            DO I_SPC = N_SPECIES(I_ST)+1, N_SPECIES(I_ST)+N_SPCCATS(I_ST)

C     Look at the species categories in what we have already looked to
C     see if we have already counted this category

               NEW_CAT = .TRUE.
               I_ST2 = 1

               DO WHILE (NEW_CAT .AND. I_ST2 .LE. I_ST)

                  I_SPC2 = N_SPECIES(I_ST2)+1

                  IF (I_ST2 .EQ. I_ST) THEN
                     SPC2_LIM = I_SPC-1
                  ELSE
                     SPC2_LIM = N_SPECIES(I_ST2) + N_SPCCATS(I_ST2)
                  END IF

                  DO WHILE (NEW_CAT .AND. I_SPC2 .LE. SPC2_LIM)

                     IF (TRIM(SPECIES(I_ST, I_SPC)) .EQ.
     &                   TRIM(SPECIES(I_ST2, I_SPC2))) THEN
                        NEW_CAT = .FALSE.
                     END IF

                     I_SPC2 = I_SPC2 + 1

                  END DO

                  I_ST2 = I_ST2 + 1

               END DO

               IF (NEW_CAT) THEN
                  COUNT_SPCCATS = COUNT_SPCCATS + 1
                  IF (FILL) THEN
                     SPCCATS(COUNT_SPCCATS) = TRIM(SPECIES(I_ST, I_SPC))
                  END IF
               END IF

            END DO
         END IF
      END DO

      END FUNCTION COUNT_SPCCATS

C     ==================================================================

      SUBROUTINE INITIALIZE_CATS()

C     This subroutine initializes the species categories. More
C     presicely, it gathers the list of species for each category and
C     calculates the weights used in the calculations of additive
C     sensitivities.

      IMPLICIT NONE

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "INITIALIZE_CATS"
      CHARACTER(LEN=LEN_MSG) :: MSG
      CHARACTER(LEN=3) :: J_STR
      INTEGER ::  STATUS, N_SPCSINCAT_MAX, N_INFILES_MAX, I, J

C     ------------------------------------------------------------------

C     Get the number of distinct species categories

      N_DISTINCT_SPCCATS = COUNT_SPCCATS(.FALSE.)

C     Get the name of each category

      ALLOCATE(SPCCATS(N_DISTINCT_SPCCATS), STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "SPCCATS memory allocation failed"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      N_DISTINCT_SPCCATS = COUNT_SPCCATS(.TRUE.)

C     Get the number of species per category and the maximum number of
C     species per category

      ALLOCATE(N_SPCSINCAT(N_DISTINCT_SPCCATS), STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "N_SPCSINCAT memory allocation failed"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      N_SPCSINCAT_MAX = -1
      DO I = 1, N_DISTINCT_SPCCATS

         CALL GET_ENV_INT("N_SPCSINCAT_" // TRIM(SPCCATS(I)),
     &        "Number of species in category " // TRIM(SPCCATS(I)),
     &        N_SPCSINCAT(I))

         IF (N_SPCSINCAT(I) .GT. N_SPCSINCAT_MAX) THEN
            N_SPCSINCAT_MAX = N_SPCSINCAT(I)
         END IF

      END DO

C     Get the maximum number of input files per category

      N_INFILES_MAX = -1
      DO I = 1, N_SENS_TYPES
         IF (N_INFILES(I) .GT. N_INFILES_MAX) THEN
            N_INFILES_MAX = N_INFILES(I)
         END IF
      END DO

C     Allocate the arrays that will contain the species lists and the
C     weights for each distinct category

      ALLOCATE(SPCSINCAT(N_DISTINCT_SPCCATS, N_SPCSINCAT_MAX), STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "SPCSINCAT memory allocation failed"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      ALLOCATE(WGT_SPCCAT(N_DISTINCT_SPCCATS, N_SENS_TYPES, 0:N_INFILES_MAX,
     &                    N_SPCSINCAT_MAX), STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "WGT_SPCCAT memory allocation failed"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

C     Fill out the array that contains the list of species name for each
C     species category

      DO I = 1, N_DISTINCT_SPCCATS
         DO J = 1, N_SPCSINCAT(I)
            WRITE(J_STR, '(I3.3)') J
            CALL GET_ENV_CHAR("SPCSINCAT_"//TRIM(SPCCATS(I))//"_"//J_STR,
     &           "Name of variable SPCSINCAT_"//TRIM(SPCCATS(I))//"_"//J_STR,
     &           SPCSINCAT(I, J))
         END DO
      END DO

C     Fill out the array of weights

      DO I = 1, N_DISTINCT_SPCCATS
         DO J = 1, N_SENS_TYPES
            CALL CALC_WGT_SPCCAT(I, SENSITIVITY_TYPES(J))
         END DO
      END DO

      END SUBROUTINE INITIALIZE_CATS

C     ==================================================================

      SUBROUTINE CALC_WGT_SPCCAT(I_SPCCAT, SENS_TYPE)

C     This subroutines calculates the weighting factors for the
C     calculation of additive sensitivities to categories of species.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     --- Arguments

      INTEGER, INTENT(IN) :: I_SPCCAT
      CHARACTER(LEN=LEN_SENS_TYPE), INTENT(IN) :: SENS_TYPE

C     --- Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "CALC_WGT_SPCCAT"
      LOGICAL :: FIRST_SPC
      CHARACTER(LEN=LEN_MSG) :: MSG
      CHARACTER(LEN=LEN_LOGICAL_NAME) :: FILE
      CHARACTER(LEN=LEN_VNAME) :: SPC
      CHARACTER(LEN=LEN_UNITS) :: UNITS
      INTEGER :: STATUS, CAT, DIM1, DIM2, DIM3, JDATE, JTIME,
     &           I_INFILE, I_ST, I_SPC, I_SPC2, I_TSTEP, I1, I2, I3
      REAL :: SUM
      REAL, ALLOCATABLE :: GRID(:,:,:)

C     ---  External functions

      INTEGER, EXTERNAL :: INDEX1

C     ------------------------------------------------------------------

      I_ST = INDEX_SENS_TYPE(SENS_TYPE)

C     If there is no category for this sensitivity type, then there is
C     nothing to do

      IF (N_SPCCATS(I_ST) .EQ. 0) THEN
         RETURN
      END IF

C     Initialize the weights for the non-weighted average

      DO I_SPC = 1, N_SPCSINCAT(I_SPCCAT)
         WGT_SPCCAT(I_SPCCAT, I_ST, 0, I_SPC) = 1./FLOAT(N_SPCSINCAT(I_SPCCAT))
      END DO

C     If there is no input file for this sensitivity type, then there is
C     nothing more to do

      IF (N_INFILES(I_ST) .EQ. 0) THEN
         RETURN
      END IF

C     Allocate the array we will use to read data

      CAT = ST_TO_CAT(SENS_TYPE)
      CALL GET_DIMS(CAT, DIM1, DIM2, DIM3)

      ALLOCATE(GRID(DIM1, DIM2, DIM3), STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "GRID memory allocation failed"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

C     Calculates the weights for weighted averages

      DO I_INFILE = 1, N_INFILES(I_ST)

         FILE = INFILES(I_ST, I_INFILE)
         FIRST_SPC = .TRUE.
         SUM = 0.

         IF (.NOT. OPEN3(FILE, FSREAD3, PNAME)) THEN
            MSG = "Could not open " // FILE // " (read-only)"
            CALL M3EXIT (PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
         END IF

         IF (.NOT. DESC3(FILE)) THEN
            MSG = "Could not get description of " // FILE
            CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
         END IF

         DO I_SPC = 1, N_SPCSINCAT(I_SPCCAT)

            SPC = SPCSINCAT(I_SPCCAT, I_SPC)
            I_SPC2 = INDEX1(SPC, NVARS3D, VNAME3D)
            WGT_SPCCAT(I_SPCCAT, I_ST, I_INFILE, I_SPC) = 0.

            IF (I_SPC2 .EQ. 0) THEN

               MSG = "Species " // TRIM(SPC) // " not found in " // FILE
               CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
               CYCLE

            END IF

C     Verify that units are the same for all the species of the category
C     and also that these units are on a molar basis

            IF (FIRST_SPC) THEN
               UNITS = UNITS3D(I_SPC2)

               IF ((SENS_TYPE .EQ. "BC") .OR. (SENS_TYPE .EQ. "IC")) THEN

                  IF ((TRIM(UNITS) .NE. "mol/m**3") .AND.
     &                (TRIM(UNITS) .NE. "ppmV"))  THEN
                     MSG = "Units of " //  TRIM(SPC) // "(" // TRIM(UNITS) //
     &                     ") not in mole basis in " // FILE
                     CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
                  END IF

               ELSE IF (SENS_TYPE .EQ. "EM") THEN

                  IF (TRIM(UNITS) .NE. "mol/s") THEN
                     MSG = "Units of " //  TRIM(SPC) // "(" // TRIM(UNITS) //
     &                     ") not in mole basis in " // FILE
                     CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
                  END IF

               END IF

               FIRST_SPC = .FALSE.

            ELSE IF (TRIM(UNITS3D(I_SPC2)) .NE. TRIM(UNITS)) THEN

               MSG = "Inconsistent units for category" // SPCCATS(I_SPCCAT) //
     &               " in " // FILE
               CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)

            END IF

C     Get the data for each time step

            JDATE = SDATE
            JTIME = STIME

            DO I_TSTEP = 1, N_TSTEPS

               IF (.NOT. READ3(FILE, SPC, ALLAYS3, JDATE, JTIME, GRID)) THEN
                  MSG = "Could not read " // TRIM(SPC) // " from " //FILE
                  CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
               END IF

C     And sum it

               DO I1 = 1, DIM1
                  DO I2 = 1, DIM2
                     DO I3 = 1, DIM3
                        WGT_SPCCAT(I_SPCCAT, I_ST, I_INFILE, I_SPC) =
     &                       WGT_SPCCAT(I_SPCCAT, I_ST, I_INFILE, I_SPC) +
     &                       GRID(I1, I2, I3)
                     END DO
                  END DO
               END DO

               CALL NEXTIME(JDATE, JTIME, TSTEP)

            END DO

C     Keep track of sum of the weights to normalize later

            SUM = SUM + WGT_SPCCAT(I_SPCCAT, I_ST, I_INFILE, I_SPC)

         END DO

C     Normalize to 1

         DO I_SPC = 1, N_SPCSINCAT(I_SPCCAT)
            IF (SUM .EQ. 0) THEN
               WGT_SPCCAT(I_SPCCAT, I_ST, I_INFILE, I_SPC) = 0.
            ELSE
               WGT_SPCCAT(I_SPCCAT, I_ST, I_INFILE, I_SPC) =
     &              WGT_SPCCAT(I_SPCCAT, I_ST, I_INFILE, I_SPC) / SUM
            END IF
         END DO

      END DO

C     Deallocate temporary grid

      DEALLOCATE(GRID, STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "GRID memory deallocation failed"
         CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
      END IF

      END SUBROUTINE CALC_WGT_SPCCAT

C     ==================================================================

      SUBROUTINE GET_DIMS(CAT, DIM1, DIM2, DIM3)

C     This subroutine gets the dimensions of the array required to read
C     or write data from and to files of category CAT.

      IMPLICIT NONE

C     --- Arguments

      INTEGER, INTENT(IN) :: CAT
      INTEGER, INTENT(OUT) :: DIM1, DIM2, DIM3

C     --- Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_DIMS"
      CHARACTER(LEN=LEN_MSG) :: MSG

C     ------------------------------------------------------------------

      IF ((CAT .EQ. 1) .OR. (CAT .EQ. 2) .OR. (CAT .EQ. 4)) THEN
         DIM1 = NCOLS(CAT)
         DIM2 = NROWS(CAT)
         DIM3 = NLAYS(CAT)
      ELSE IF (CAT .EQ. 3) THEN
         IF (NTHIK(CAT) .NE. 1) THEN
            MSG = "NTHIK non-equal to 1 not supported"
            CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
         END IF
         DIM1 = 2*NCOLS(CAT) + 2*NROWS(CAT) + 4
         DIM2 = NLAYS(CAT)
         DIM3 = 1
      ELSE
         WRITE(MSG, '(A, I1)') "Unknown category: ", CAT
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      END SUBROUTINE GET_DIMS

C     ==================================================================

      SUBROUTINE FINALIZE()

C     This subroutine finlaizes the adjpost run. More precisely, it
C     closes input and output files that are open and deallocates all
C     arrays that are still allocated.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "FINALIZE"
      CHARACTER(LEN=LEN_MSG) :: MSG
      CHARACTER(LEN=LEN_LOGICAL_NAME) :: FILE
      INTEGER :: STATUS, I_ST, I_INFILE

C     ------------------------------------------------------------------

C     Close all open input and output files

      FILE = "METCRO3D"
      IF (.NOT. CLOSE3(FILE)) THEN
         MSG = "Could not close file: " // FILE
         CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
      END IF

      FILE = "METDOT3D"
      IF (.NOT. CLOSE3(FILE)) THEN
         MSG = "Could not close file: " // FILE
         CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
      END IF

      FILE = "METBDY3D"
      IF (.NOT. CLOSE3(FILE)) THEN
         MSG = "Could not close file: " // FILE
         CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
      END IF

      FILE = "INFILE_ADJ"
      IF (.NOT. CLOSE3(FILE)) THEN
         MSG = "Could not close file: " // FILE
         CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
      END IF

      DO I_ST = 1, N_SENS_TYPES
         DO I_INFILE = 1, N_INFILES(I_ST)
            FILE = INFILES(I_ST, I_INFILE)
            IF (.NOT. CLOSE3(FILE)) THEN
               MSG = "Could not close file: " // FILE
               CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
            END IF
         END DO
      END DO

C     Deallocate arrays related to input and output files

      IF (ALLOCATED(INFILES)) THEN
         DEALLOCATE(INFILES, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "INFILES memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(NICKNAMES)) THEN
         DEALLOCATE(NICKNAMES, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "NICKNAMES memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(TREATMENTS)) THEN
         DEALLOCATE(TREATMENTS, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "TREATMENTS memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

C     Deallocate arrays related to species and species categories

      IF (ALLOCATED(SPECIES)) THEN
         DEALLOCATE(SPECIES, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "SPECIES memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(SPCCATS)) THEN
         DEALLOCATE(SPCCATS, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "SPCCATS memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(N_SPCSINCAT)) THEN
         DEALLOCATE(N_SPCSINCAT, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "N_SPCSINCAT memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(SPCSINCAT)) THEN
         DEALLOCATE(SPCSINCAT, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "SPCSINCAT memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

C     Deallocate arrays that contain physical quanitities

      IF (ALLOCATED(DZ_GRID)) THEN
         DEALLOCATE(DZ_GRID, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "DZ_GRID memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(DZ_BDY)) THEN
         DEALLOCATE(DZ_BDY, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "DZ_BDY memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(PRES_GRID)) THEN
         DEALLOCATE(PRES_GRID, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "PRES_GRID memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(PRES_BDY)) THEN
         DEALLOCATE(PRES_BDY, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "PRES_BDY memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(TA_GRID)) THEN
         DEALLOCATE(TA_GRID, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "TA_GRID memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(TA_BDY)) THEN
         DEALLOCATE(TA_BDY, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "TA_BDY memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(INFLOW_BDY)) THEN
         DEALLOCATE(INFLOW_BDY, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "INFLOW_BDY memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(WGT_SPCCAT)) THEN
         DEALLOCATE(WGT_SPCCAT, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "WGT_SPCCAT memory deallocation failed"
            CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(BC_BDY)) THEN
         DEALLOCATE(BC_BDY, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "BC_BDY memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(IC_GRID)) THEN
         DEALLOCATE(IC_GRID, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "IC_GRID memory deallocation failed"
            CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(EM_GRID)) THEN
         DEALLOCATE(EM_GRID, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "EM_GRID memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(ADJ_GRID)) THEN
         DEALLOCATE(ADJ_GRID, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "ADJ_GRID memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      IF (ALLOCATED(ADJ_BDY)) THEN
         DEALLOCATE(ADJ_BDY, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "ADJ_BDY memory deallocation failed"
            CALL M3WARN(PNAME, JDATE_NONE, JTIME_NONE, MSG)
         END IF
      END IF

      END SUBROUTINE FINALIZE

C     ==================================================================

      SUBROUTINE GET_ENV_INT(NAME, DESC, VALUE, DEFAULT)

C     This subroutine fetches integer environment variables.
C
C      - NAME: Name of the environment variable.
C      - DESC: Short description of the environment variable.
C      - VALUE: Returned value.
C      - DEFAULT (optional): Default value.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL

C     ---  Arguments

      CHARACTER(LEN=*), INTENT(IN) :: NAME, DESC
      INTEGER, INTENT(OUT) :: VALUE
      INTEGER, OPTIONAL, INTENT(IN) :: DEFAULT

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_ENV_INT"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      INTEGER, SAVE :: LOG
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: DEF, STATUS

C     ---  External functions

      INTEGER, EXTERNAL :: ENVINT

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN
         LOG = INIT3()
         FIRSTTIME = .FALSE.
      END IF

      IF (PRESENT(DEFAULT)) THEN
         DEF = DEFAULT
      ELSE
         DEF = 0
      END IF

      WRITE(LOG, '(/, 5X, A)') "Reading environment variable: " // name
      WRITE(LOG, '(5X, A)') "Description: " // desc

      VALUE = ENVINT(NAME, DESC, DEF, STATUS)

      IF (STATUS .EQ. 1) THEN
         MSG = "Environment variable improperly formatted"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      ELSE IF ((STATUS .EQ. -1) .AND. (PRESENT(DEFAULT))) THEN
         MSG = "Environment variable set but empty. Using default: "
         WRITE(LOG, '(5X, A)') MSG
      ELSE IF (STATUS .EQ. -1) THEN
         MSG = "Environment variable set but empty and no default"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      ELSE IF ((STATUS .EQ. -2) .AND. (PRESENT(DEFAULT))) THEN
         MSG = "Environment variable not set. Using default"
         WRITE(LOG, '(5X, A)') MSG
      ELSE IF (STATUS .EQ. -2) THEN
         MSG = "Environment variable not set and no default"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      ELSE IF (STATUS .NE. 0) THEN
         MSG = "Unknown error code"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      WRITE(LOG, '(5X, A, I10)') "Environment variable " // name //
     &                           " set to: ", VALUE

      END SUBROUTINE GET_ENV_INT

C     ==================================================================

      SUBROUTINE GET_ENV_CHAR(NAME, DESC, VALUE, DEFAULT)

C     Get character environment variable
C
C      - NAME: Name of the environment variable.
C      - DESC: Short description of the environment variable.
C      - VALUE: Returned value.
C      - DEFAULT (optional): Default value.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL

C     ---  Arguments

      CHARACTER(LEN=*), INTENT(IN) :: NAME,
     &                                DESC
      CHARACTER(LEN=*), INTENT(OUT) :: VALUE
      CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: DEFAULT

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_ENV_CHAR"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      INTEGER, SAVE :: LOG
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: STATUS

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN
         LOG = INIT3()
         FIRSTTIME = .FALSE.
      END IF

      WRITE(LOG, '(/, 5X, A)') "Reading environment variable: " // name
      WRITE(LOG, '(5X, A)') "Description: " // desc

      IF (PRESENT(DEFAULT)) THEN
         CALL ENVSTR(NAME, DESC, DEFAULT, VALUE, STATUS)
      ELSE
         CALL ENVSTR(NAME, DESC, "N/A", VALUE, STATUS)
      END IF

      IF (STATUS .EQ. 1) THEN
         MSG = "Environment variable improperly formatted"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      ELSE IF ((STATUS .EQ. -1) .AND. (PRESENT(DEFAULT))) THEN
         MSG = "Environment variable set but empty. Using default: "
         WRITE(LOG, '(5X, A)') MSG
      ELSE IF (STATUS .EQ. -1) THEN
         MSG = "Environment variable set but empty and no default"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      ELSE IF ((STATUS .EQ. -2) .AND. (PRESENT(DEFAULT))) THEN
         MSG = "Environment variable not set. Using default"
         WRITE(LOG, '(5X, A)') MSG
      ELSE IF (STATUS .EQ. -2) THEN
         MSG = "Environment variable not set and no default"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      ELSE IF (STATUS .NE. 0) THEN
         MSG = "Unknown error code"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      WRITE(LOG, '(5X, A, A)') "Environment variable " // name //
     &                         " set to: ", VALUE

      END SUBROUTINE GET_ENV_CHAR

C     ==================================================================

      INTEGER FUNCTION FILE_CAT(FILE)

C     This function return the file category number of file with logical
C     name FILE.

      IMPLICIT NONE

C     ---  Arguments

      CHARACTER(LEN=LEN_LOGICAL_NAME) :: FILE

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "FILE_CAT"
      CHARACTER(LEN=LEN_MSG) :: MSG

C     ------------------------------------------------------------------

      IF (FILE .EQ. "METCRO3D") THEN
         FILE_CAT = 1
      ELSE IF (FILE .EQ. "METBDY3D") THEN
         FILE_CAT = 3
      ELSE IF (FILE .EQ. "METDOT3D") THEN
         FILE_CAT = 4
      ELSE IF (FILE .EQ. "INFILE_ADJ") THEN
         FILE_CAT = 1
      ELSE IF (STARTS_WITH(FILE, "INFILE_BC_")) THEN
         FILE_CAT = 3
      ELSE IF (STARTS_WITH(FILE, "INFILE_IC_")) THEN
         FILE_CAT = 1
      ELSE IF (STARTS_WITH(FILE, "INFILE_EM_")) THEN
         FILE_CAT = 2
      ELSE IF (STARTS_WITH(FILE, "OUTFILE_BC_")) THEN
         FILE_CAT = 3
      ELSE IF (STARTS_WITH(FILE, "OUTFILE_IC_")) THEN
         FILE_CAT = 1
      ELSE IF (STARTS_WITH(FILE, "OUTFILE_EM_")) THEN
         FILE_CAT = 2
      ELSE
         MSG = "Unknown file logical name: " // FILE
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      END FUNCTION FILE_CAT

C     ==================================================================

      INTEGER FUNCTION ST_TO_CAT(SENS_TYPE)

C     This function returns the file category number corresponding to
C     sensitivity type SENS_TYPE.

      IMPLICIT NONE

C     ---  Arguments

      CHARACTER(LEN=LEN_SENS_TYPE) :: SENS_TYPE

C     ---  Local variables

      CHARACTER(LEN=LEN_LOGICAL_NAME) :: FILE

C     ------------------------------------------------------------------

      FILE = "INFILE_" // SENS_TYPE // "_001"
      ST_TO_CAT = FILE_CAT(FILE)

      END FUNCTION ST_TO_CAT

C     ==================================================================

      LOGICAL FUNCTION STARTS_WITH(PARENT, CHILD)

C     This function returns .TRUE. if PARENT string starts with CHILD
C     string and .FALSE. otherwise.

      IMPLICIT NONE

C     ---  Arguments

      CHARACTER(LEN=*), INTENT(IN) :: PARENT, CHILD

C     ---  Local variables

      INTEGER :: LEN_PARENT, LEN_CHILD

C     ------------------------------------------------------------------

      LEN_PARENT = LEN_TRIM(PARENT)
      LEN_CHILD = LEN_TRIM(CHILD)

      IF (LEN_CHILD .GT. LEN_PARENT) THEN
         STARTS_WITH = .FALSE.
      ELSE
         STARTS_WITH = (PARENT(1:LEN_CHILD) .EQ. CHILD)
      END IF

      END FUNCTION STARTS_WITH

C     ==================================================================

      INTEGER FUNCTION INDEX_SPCCAT(SPCCAT)

C     Return the index of species category SPCCAT in SPCCATS.

      IMPLICIT NONE

C     ---  Arguments

      CHARACTER(LEN=LEN_VNAME), INTENT(IN) :: SPCCAT

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "INDEX_SPCCAT"
      CHARACTER(LEN=LEN_MSG) :: MSG

C     ------------------------------------------------------------------

      INDEX_SPCCAT = 1
      DO WHILE ((SPCCATS(INDEX_SPCCAT) .NE. SPCCAT) .AND.
     &          (INDEX_SPCCAT .LT. N_DISTINCT_SPCCATS))
         INDEX_SPCCAT = INDEX_SPCCAT + 1
      END DO

      IF (SPCCATS(INDEX_SPCCAT) .NE. SPCCAT) THEN
         MSG = "Species category " // TRIM(SPCCAT) // " not found"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      END FUNCTION INDEX_SPCCAT

C     ==================================================================

      INTEGER FUNCTION INDEX_SENS_TYPE(SENS_TYPE)

C     Return the index of sensitivity type SENS_TYPE in
C     SENSITIVITY_TYPES.

      IMPLICIT NONE

C     ---  Arguments

      CHARACTER(LEN=LEN_SENS_TYPE), INTENT(IN) :: SENS_TYPE

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "INDEX_SENS_TYPE"
      CHARACTER(LEN=LEN_MSG) :: MSG

C     ------------------------------------------------------------------

      INDEX_SENS_TYPE = 1
      DO WHILE ((SENSITIVITY_TYPES(INDEX_SENS_TYPE) .NE. SENS_TYPE) .AND.
     &          (INDEX_SENS_TYPE .LT. N_SENS_TYPES))
         INDEX_SENS_TYPE = INDEX_SENS_TYPE + 1
      END DO

      IF (SENSITIVITY_TYPES(INDEX_SENS_TYPE) .NE. SENS_TYPE) THEN
         MSG = "Sensitivity type " // SENS_TYPE // " not found"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      END FUNCTION INDEX_SENS_TYPE

C     ==================================================================

      SUBROUTINE GET_IC_GRID(JDATE, JTIME, SPC, I_INFILE)

C     This subroutine fetces initial conditions for species SPC, date
C     JDATE, and time JTIME from input file with index I_INFILE. The
C     result is returned in mol/m**3.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME, I_INFILE
      CHARACTER(LEN=LEN_VNAME), INTENT(IN) :: SPC

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_IC_GRID"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      CHARACTER(LEN=LEN_VNAME), SAVE :: SPC_LAST
      INTEGER, SAVE :: DIM1, DIM2, DIM3, I_ST,
     &                 JDATE_LAST = -1, JTIME_LAST = -1,
     &                 I_INFILE_LAST = -1
      CHARACTER(LEN=LEN_MSG) :: MSG
      CHARACTER(LEN=LEN_LOGICAL_NAME) :: FILE
      INTEGER :: I_SPC, STATUS, I1, I2, I3

C     ---  External function

      INTEGER, EXTERNAL :: INDEX1

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

C     Allocate the array that will store the data

         I_ST = INDEX_SENS_TYPE("IC")
         CALL GET_DIMS(FILE_CAT(INFILES(I_ST, I_INFILE)), DIM1, DIM2, DIM3)
         ALLOCATE(IC_GRID(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "IC_GRID memory allocation failed"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

         FIRSTTIME = .FALSE.
      END IF

C     Nothing to do if we are reading the same quantity as last time

      IF ((JDATE .EQ. JDATE_LAST) .AND. (JTIME .EQ. JTIME_LAST) .AND.
     &    (TRIM(SPC) .EQ. TRIM(SPC_LAST)) .AND.
     &    (I_INFILE .EQ. I_INFILE_LAST)) THEN
         RETURN
      END IF

C     Otherwise open the file and read the data (or set to zero if
C     species not in file)

      FILE = INFILES(I_ST, I_INFILE)

      IF (.NOT. OPEN3(FILE, FSREAD3, PNAME)) THEN
         MSG = "Could not open " // FILE // " (read-only)"
         CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

      IF (.NOT. DESC3(FILE)) THEN
         MSG = "Could not get description of " // FILE
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

      I_SPC = INDEX1(TRIM(SPC), NVARS3D, VNAME3D)
      IF (I_SPC .EQ. 0) THEN

         MSG = "Species " // TRIM(SPC) // " not found in " // FILE
         CALL M3WARN(PNAME, JDATE, JTIME, MSG)

         IC_GRID = 0.

      ELSE

         IF (.NOT. READ3(FILE, SPC, ALLAYS3, JDATE, JTIME, IC_GRID)) THEN
            MSG = "Could not read " // TRIM(SPC) // " data from " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

C     Unit check and conversion if necessary

         IF ((TRIM(UNITS3D(I_SPC)) .EQ. "ppmV")) THEN

            CALL GET_PRES_GRID(JDATE, JTIME)
            CALL GET_TA_GRID(JDATE, JTIME)

            DO I1 = 1, DIM1
               DO I2 = 1, DIM2
                  DO I3 = 1, DIM3
                     IC_GRID(I1, I2, I3) = IC_GRID(I1, I2, I3) *
     &                    PRES_GRID(I1, I2, I3) / CONST_R /
     &                    TA_GRID(I1, I2, I3) * CONST_PPMV2FRAC
                  END DO
               END DO
            END DO

         ELSE IF (TRIM(UNITS3D(I_SPC)) .NE. "mol/m**3") THEN

            MSG = "Bad units (" // TRIM(UNITS3D(I_SPC)) //
     &            ") for " // TRIM(SPC) // " in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)

         END IF

      END IF

C     Save the information about what data we just read

      JDATE_LAST = JDATE
      JTIME_LAST = JTIME
      SPC_LAST = SPC
      I_INFILE_LAST = I_INFILE

      END SUBROUTINE GET_IC_GRID


C     ==================================================================

      SUBROUTINE GET_INFLOW_BDY(JDATE, JTIME)

C     This subroutine gets the wind inflow on the boundary at date JDATE
C     and time JTIME. Wind inflow here means the component of the wind
C     normal to the boundary if it is positive (zero otherwise)
C     multiplied by the horizontal width of a grid cell in the direction
C     of the boundary (XCELL for North and South boundaries and YCELL
C     for East and West boundaries). The result is returned in m**2/s.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_INFLOW_BDY"
      CHARACTER(LEN=LEN_LOGICAL_NAME), PARAMETER :: FILE_BDY = "METBDY3D",
     &                                              FILE_DOT = "METDOT3D"
      CHARACTER(LEN=LEN_VNAME), PARAMETER :: UNAME = "UWIND",
     &                                       VNAME = "VWIND"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      INTEGER, SAVE :: CAT, JDATE_LAST = -1, JTIME_LAST = -1,
     &                 DIM1, DIM2, DIM3
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: STATUS, IDX_START, IDX_END, I1, I2, I3
      REAL :: WIND
      REAL, ALLOCATABLE :: TEMP(:,:,:)

C     ---  External functions

      INTEGER, EXTERNAL :: INDEX1

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

C     Allocate the array that will store the data

         CALL GET_DIMS(FILE_CAT(FILE_BDY), DIM1, DIM2, DIM3)
         ALLOCATE(INFLOW_BDY(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "INFLOW_BDY memory allocation failed"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

         INFLOW_BDY = 0.

C     Open the file to read

         IF (.NOT. OPEN3(FILE_DOT, FSREAD3, PNAME)) THEN
            MSG = "Could not open " // FILE_DOT // " (read-only)"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

C     Check units of U velocity

         IF (.NOT. DESC3(FILE_DOT)) THEN
            MSG = "Could not get description of " // FILE_DOT
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         I1 = INDEX1(TRIM(UNAME), NVARS3D, VNAME3D)
         IF (I1 .EQ. 0) THEN
            MSG = "Variable " // TRIM(UNAME) // " not found in " // FILE_DOT
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         IF ((TRIM(UNITS3D(I1)) .NE. "M/S") .AND.
     7       (TRIM(UNITS3D(I1)) .NE. "m/s")) THEN
            MSG = "Bad units (" // TRIM(UNITS3D(I1)) //
     &            ") for " // TRIM(UNAME) // " in " // FILE_DOT
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

C     Check units of V velocity

         I1 = INDEX1(TRIM(VNAME), NVARS3D, VNAME3D)
         IF (I1 .EQ. 0) THEN
            MSG = "Variable " // TRIM(VNAME) // " not found in " // FILE_DOT
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         IF ((TRIM(UNITS3D(I1)) .NE. "M/S") .AND.
     7       (TRIM(UNITS3D(I1)) .NE. "m/s")) THEN
            MSG = "Bad units (" // TRIM(UNITS3D(I1)) //
     &            ") for " // TRIM(VNAME) // " in " // FILE_DOT
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

C     Get the dimensions of the array used to read from the input file

         CAT = FILE_CAT(FILE_DOT)
         CALL GET_DIMS(CAT, DIM1, DIM2, DIM3)

         FIRSTTIME = .FALSE.
      END IF

C     Nothing to do if we are reading the same quantity as last time

      IF ((JDATE .EQ. JDATE_LAST) .AND. (JTIME .EQ. JTIME_LAST)) THEN
         RETURN
      END IF

C     Otherwise we need a temporary array to read the data

      ALLOCATE(TEMP(DIM1, DIM2, DIM3), STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "TEMP memory allocation failed"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

C     West and East boundaries

      IF (.NOT. READ3(FILE_DOT, UNAME, ALLAYS3, JDATE, JTIME, TEMP)) THEN
         MSG = "Could not read " // TRIM(UNAME) // " data from " // FILE_DOT
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

      CALL INDICES_BDY("W", IDX_START, IDX_END)

      DO I2 = 1, IDX_END-IDX_START+1
         DO I3 = 1, DIM3
            WIND = 0.5*(TEMP(1,I2,I3) + TEMP(1,I2+1,I3))
            IF (WIND .GT. 0.) THEN
               INFLOW_BDY(IDX_START+I2-1,I3,1) = WIND * YCELL(CAT)
            ELSE
               INFLOW_BDY(IDX_START+I2-1,I3,1) = 0.
            END IF
         END DO
      END DO

      CALL INDICES_BDY("E", IDX_START, IDX_END)

      DO I2 = 1, IDX_END-IDX_START+1
         DO I3 = 1, DIM3
            WIND = 0.5*(TEMP(DIM1,I2,I3) + TEMP(DIM1,I2+1,I3))
            IF (WIND .LT. 0.) THEN
               INFLOW_BDY(IDX_START+I2-1,I3,1) = - WIND * YCELL(CAT)
            ELSE
               INFLOW_BDY(IDX_START+I2-1,I3,1) = 0.
            END IF
         END DO
      END DO

C     South and North boundaries

      IF (.NOT. READ3(FILE_DOT, VNAME, ALLAYS3, JDATE, JTIME, TEMP)) THEN
         MSG = "Could not read " // TRIM(VNAME) // " data from " // FILE_DOT
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

      CALL INDICES_BDY("S", IDX_START, IDX_END)

      DO I1 = 1, IDX_END-IDX_START+1
         DO I3 = 1, DIM3
            WIND = 0.5*(TEMP(I1,1,I3) + TEMP(I1+1,1,I3))
            IF (WIND .GT. 0.) THEN
               INFLOW_BDY(IDX_START+I1-1,I3,1) = WIND * XCELL(CAT)
            ELSE
               INFLOW_BDY(IDX_START+I1-1,I3,1) = 0.
            END IF
         END DO
      END DO

      CALL INDICES_BDY("N", IDX_START, IDX_END)

      DO I1 = 1, IDX_END-IDX_START+1
         DO I3 = 1, DIM3
            WIND = 0.5*(TEMP(I1,DIM2,I3) + TEMP(I1+1,DIM2,I3))
            IF (WIND .LT. 0.) THEN
               INFLOW_BDY(IDX_START+I1-1,I3,1) = - WIND * XCELL(CAT)
            ELSE
               INFLOW_BDY(IDX_START+I1-1,I3,1) = 0.
            END IF
         END DO
      END DO

C     Deallocate the temporary array

      DEALLOCATE(TEMP, STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "TEMP memory allocation failed"
         CALL M3WARN(PNAME, JDATE, JTIME, MSG)
      END IF

C     Save the information about what data we just read

      JDATE_LAST = JDATE
      JTIME_LAST = JTIME

      END SUBROUTINE GET_INFLOW_BDY

C     ==================================================================

      SUBROUTINE GET_BC_BDY(JDATE, JTIME, SPC, I_INFILE)

C     This subroutine fetches the boundary conditions at date JDATE and
C     time JTIME for species SPC. The result is returned in mol/m**3.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME, I_INFILE
      CHARACTER(LEN=LEN_VNAME), INTENT(IN) :: SPC

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_BC_BDY"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      CHARACTER(LEN=LEN_VNAME), SAVE :: SPC_LAST
      INTEGER, SAVE :: JDATE_LAST = -1, JTIME_LAST = -1, I_INFILE_LAST = -1,
     &                 DIM1, DIM2, DIM3, I_ST
      CHARACTER(LEN=LEN_MSG) :: MSG
      CHARACTER(LEN=LEN_LOGICAL_NAME) :: FILE
      INTEGER :: STATUS, I_SPC, I1, I2, I3

C     ---  External function

      INTEGER, EXTERNAL :: INDEX1

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

C     Allocate the array that will store the data

         I_ST = INDEX_SENS_TYPE("BC")
         CALL GET_DIMS(FILE_CAT(INFILES(I_ST, I_INFILE)), DIM1, DIM2, DIM3)
         ALLOCATE(BC_BDY(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "BC_BDY memory allocation failed"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

         FIRSTTIME = .FALSE.
      END IF

C     Nothing to do if we are reading the same quantity as last time

      IF ((JDATE .EQ. JDATE_LAST) .AND. (JTIME .EQ. JTIME_LAST) .AND.
     &    (TRIM(SPC) .EQ. TRIM(SPC_LAST)) .AND.
     &    (I_INFILE .EQ. I_INFILE_LAST)) THEN
         RETURN
      END IF

C     Otherwise open the file and read the data (or set to zero if
C     species not in file)

      FILE = INFILES(I_ST, I_INFILE)

      IF (.NOT. OPEN3(FILE, FSREAD3, PNAME)) THEN
         MSG = "Could not open " // FILE // " (read-only)"
         CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

      IF (.NOT. DESC3(FILE)) THEN
         MSG = "Could not get description of " // FILE
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

      I_SPC = INDEX1(TRIM(SPC), NVARS3D, VNAME3D)

      IF (I_SPC .EQ. 0) THEN

         MSG = "Species " // TRIM(SPC) // " not found in " // FILE
         CALL M3WARN(PNAME, JDATE, JTIME, MSG)

         BC_BDY = 0.

      ELSE

         IF (.NOT. READ3(FILE, SPC, ALLAYS3, JDATE, JTIME, BC_BDY)) THEN
            MSG = "Could not read " // TRIM(SPC) // " data from " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

C     Unit check and conversion if necessary

         IF ((TRIM(UNITS3D(I_SPC)) .EQ. "ppmV")) THEN

            CALL GET_PRES_BDY(JDATE, JTIME)
            CALL GET_TA_BDY(JDATE, JTIME)

            DO I1 = 1, DIM1
               DO I2 = 1, DIM2
                  DO I3 = 1, DIM3
                     BC_BDY(I1, I2, I3) = BC_BDY(I1, I2, I3) *
     &                    PRES_BDY(I1, I2, I3) / CONST_R /
     &                    TA_BDY(I1, I2, I3) * CONST_PPMV2FRAC
                  END DO
               END DO
            END DO

         ELSE IF (TRIM(UNITS3D(I_SPC)) .NE. "mol/m**3") THEN

            MSG = "Bad units (" // TRIM(UNITS3D(I_SPC)) //
     &            ") for " // TRIM(SPC) // " in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)

         END IF

      END IF

C     Save the information about what data we just read

      JDATE_LAST = JDATE
      JTIME_LAST = JTIME
      SPC_LAST = SPC
      I_INFILE_LAST = I_INFILE

      END SUBROUTINE GET_BC_BDY

C     ==================================================================

      SUBROUTINE GET_EM_GRID(JDATE, JTIME, SPC, I_INFILE)

C     This subroutine fetches the emission rates at date JDATE and time
C     JTIME for species SPC. The result is returned in mol/s/m**2.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME, I_INFILE
      CHARACTER(LEN=LEN_VNAME), INTENT(IN) :: SPC

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_EM_GRID"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      CHARACTER(LEN=LEN_VNAME), SAVE :: SPC_LAST
      INTEGER, SAVE :: CAT, I_ST, DIM1, DIM2, DIM3,
     &                 JDATE_LAST = -1, JTIME_LAST = -1, I_INFILE_LAST = -1
      CHARACTER(LEN=LEN_MSG) :: MSG
      CHARACTER(LEN=LEN_LOGICAL_NAME) :: FILE
      INTEGER :: STATUS, I_SPC, I1, I2, I3
      REAL :: FAC

C     ---  External function

      INTEGER, EXTERNAL :: INDEX1

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

C     Allocate the array that will store the data

         I_ST = INDEX_SENS_TYPE("EM")
         CAT = FILE_CAT(INFILES(I_ST, I_INFILE))
         CALL GET_DIMS(CAT, DIM1, DIM2, DIM3)
         ALLOCATE(EM_GRID(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "EM_GRID memory allocation failed"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

         FIRSTTIME = .FALSE.
      END IF

C     Nothing to do if we are reading the same quantity as last time

      IF ((JDATE .EQ. JDATE_LAST) .AND. (JTIME .EQ. JTIME_LAST) .AND.
     &    (TRIM(SPC) .EQ. TRIM(SPC_LAST)) .AND.
     &    (I_INFILE .EQ. I_INFILE_LAST)) THEN
         RETURN
      END IF

C     Otherwise open the file and read the data (or set to zero if
C     species not in file)

      FILE = INFILES(I_ST, I_INFILE)

      IF (.NOT. OPEN3(FILE, FSREAD3, PNAME)) THEN
         MSG = "Could not open " // FILE // " (read-only)"
         CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

      IF (.NOT. DESC3(FILE)) THEN
         MSG = "Could not get description of " // FILE
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

      I_SPC = INDEX1(TRIM(SPC), NVARS3D, VNAME3D)

      IF (I_SPC .EQ. 0) THEN

         MSG = "Species " // TRIM(SPC) // " not found in " // FILE
         CALL M3WARN(PNAME, JDATE, JTIME, MSG)

         EM_GRID = 0.

      ELSE

         IF (.NOT. READ3(FILE, SPC, ALLAYS3, JDATE, JTIME, EM_GRID)) THEN
            MSG = "Could not read " // TRIM(SPC) // " data from " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

C     Unit conversion

         IF (TRIM(UNITS3D(I_SPC)) .EQ. "mol/s") THEN

            FAC = 1. / (XCELL(CAT) * YCELL(CAT))
            DO I1 = 1, DIM1
               DO I2 = 1, DIM2
                  DO I3 = 1, DIM3
                     EM_GRID(I1, I2, I3) = EM_GRID(I1, I2, I3) * FAC
                  END DO
               END DO
            END DO

         ELSE

            MSG = "Bad units (" // TRIM(UNITS3D(I_SPC)) //
     &           ") for " // TRIM(SPC) // " in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)

         END IF

      END IF

C     Save the information about what data we just read

      JDATE_LAST = JDATE
      JTIME_LAST = JTIME
      SPC_LAST = SPC
      I_INFILE_LAST = I_INFILE

      END SUBROUTINE GET_EM_GRID

C     ==================================================================

      SUBROUTINE GET_ADJ_GRID(JDATE, JTIME, SPC)

C     This subroutine fetches the adjoint variable at date JDATE and
C     time JTIME for species SPC. The result is returned without unit
C     conversion.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME
      CHARACTER(LEN=LEN_VNAME), INTENT(IN) :: SPC

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_ADJ_GRID"
      CHARACTER(LEN=LEN_LOGICAL_NAME), PARAMETER :: FILE = "INFILE_ADJ"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      CHARACTER(LEN=LEN_VNAME), SAVE :: SPC_LAST
      INTEGER, SAVE :: JDATE_LAST = -1, JTIME_LAST = -1
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: STATUS, DIM1, DIM2, DIM3, I_SPC

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

C     Allocate the array that will store the data

         CALL GET_DIMS(FILE_CAT(FILE), DIM1, DIM2, DIM3)
         ALLOCATE(ADJ_GRID(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "ADJ_GRID memory allocation failed"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

C     Open the file to read

         IF (.NOT. OPEN3(FILE, FSREAD3, PNAME)) THEN
            MSG = "Could not open " // FILE // " (read-only)"
            CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         FIRSTTIME = .FALSE.
      END IF

C     Nothing to do if we are reading the same quantity as last time

      IF ((JDATE .EQ. JDATE_LAST) .AND. (JTIME .EQ. JTIME_LAST) .AND.
     &    (TRIM(SPC) .EQ. TRIM(SPC_LAST))) THEN
         RETURN
      END IF

C     Otherwise read the data

      IF (.NOT. READ3(FILE, SPC, ALLAYS3, JDATE, JTIME, ADJ_GRID)) THEN
         MSG = "Could not read " // TRIM(SPC) // " data from " // FILE
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

C     Save the information about what data we just read

      JDATE_LAST = JDATE
      JTIME_LAST = JTIME
      SPC_LAST = SPC

      END SUBROUTINE GET_ADJ_GRID

C     ==================================================================

      SUBROUTINE GET_ADJ_BDY(JDATE, JTIME, SPC)

C     This subroutine fetches the adjoint variable at date JDATE and
C     time JTIME on the boundary for species SPC. The result is returned
C     without unit conversion.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME
      CHARACTER(LEN=LEN_VNAME), INTENT(IN) :: SPC

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_ADJ_BDY"
      CHARACTER(LEN=LEN_LOGICAL_NAME), PARAMETER :: FILE = "INFILE_ADJ"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      CHARACTER(LEN=LEN_VNAME), SAVE :: SPC_LAST
      INTEGER, SAVE :: DIM1, DIM2, DIM3,
     &                 JDATE_LAST = -1, JTIME_LAST = -1
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: STATUS, I_SPC, IDX_START, IDX_END, I1, I2, I3

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

C     Allocate the array that will store the data

         CALL GET_DIMS(3, DIM1, DIM2, DIM3)
         ALLOCATE(ADJ_BDY(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "ADJ_BDY memory allocation failed"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

         ADJ_BDY = 0.

C     Get the dimensions of the array used to read from the input file

         CALL GET_DIMS(FILE_CAT(FILE), DIM1, DIM2, DIM3)

         FIRSTTIME = .FALSE.
      END IF

C     Nothing to do if we are reading the same quantity as last time

      IF ((JDATE .EQ. JDATE_LAST) .AND. (JTIME .EQ. JTIME_LAST) .AND.
     &    (TRIM(SPC) .EQ. TRIM(SPC_LAST))) THEN
         RETURN
      END IF

C     Otherwise get the corresponding adjoint variable grid

      CALL GET_ADJ_GRID(JDATE, JTIME, SPC)

C     West and East boundaries

      CALL INDICES_BDY("W", IDX_START, IDX_END)

      DO I2 = 1, IDX_END-IDX_START+1
         DO I3 = 1, DIM3
            ADJ_BDY(IDX_START+I2-1,I3,1) = ADJ_GRID(1, I2, I3)
         END DO
      END DO

      CALL INDICES_BDY("E", IDX_START, IDX_END)

      DO I2 = 1, IDX_END-IDX_START+1
         DO I3 = 1, DIM3
            ADJ_BDY(IDX_START+I2-1,I3,1) = ADJ_GRID(DIM1, I2, I3)
         END DO
      END DO

C     South and North boundaries

      CALL INDICES_BDY("S", IDX_START, IDX_END)

      DO I1 = 1, IDX_END-IDX_START+1
         DO I3 = 1, DIM3
            ADJ_BDY(IDX_START+I1-1,I3,1) = ADJ_GRID(I1, 1, I3)
         END DO
      END DO

      CALL INDICES_BDY("N", IDX_START, IDX_END)

      DO I1 = 1, IDX_END-IDX_START+1
         DO I3 = 1, DIM3
            ADJ_BDY(IDX_START+I1-1,I3,1) = ADJ_GRID(I1, DIM2, I3)
         END DO
      END DO

C     Save the information about what data we just read

      JDATE_LAST = JDATE
      JTIME_LAST = JTIME
      SPC_LAST = SPC

      END SUBROUTINE GET_ADJ_BDY

C     ==================================================================

      SUBROUTINE GET_DZ_GRID(JDATE, JTIME)

C     This subroutine fetches the width of vertical layers at date JDATE
C     and time JTIME. The result is returned in m.

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_DZ_GRID"
      CHARACTER(LEN=LEN_LOGICAL_NAME), PARAMETER :: FILE = "METCRO3D"
      CHARACTER(LEN=LEN_VNAME), PARAMETER :: VNAME = "ZF"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      INTEGER, SAVE :: DIM1, DIM2, DIM3,
     &                 JDATE_LAST = -1, JTIME_LAST = -1
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: STATUS, I1, I2, I3

C     ---  External function

      INTEGER, EXTERNAL :: INDEX1

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

C     Allocate the array that will store the data

         CALL GET_DIMS(FILE_CAT(FILE), DIM1, DIM2, DIM3)
         ALLOCATE(DZ_GRID(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "DZ_GRID memory allocation failed"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

C     Open the file to read

         IF (.NOT. OPEN3(FILE, FSREAD3, PNAME)) THEN
            MSG = "Could not open " // FILE // " (read-only)"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

C     Unit check

         IF (.NOT. DESC3(FILE)) THEN
            MSG = "Could not get description of " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         I1 = INDEX1(TRIM(VNAME), NVARS3D, VNAME3D)
         IF (I1 .EQ. 0) THEN
            MSG = "Variable " // TRIM(VNAME) // " not found in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         IF ((TRIM(UNITS3D(I1)) .NE. "m") .AND.
     &       (TRIM(UNITS3D(I1)) .NE. "M")) THEN
            MSG = "Bad units (" // TRIM(UNITS3D(I1)) //
     &            ") for " // TRIM(VNAME) // " in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

         FIRSTTIME = .FALSE.

      END IF

C     Nothing to do if we are reading the same quantity as last time

      IF ((JDATE .EQ. JDATE_LAST) .AND. (JTIME .EQ. JTIME_LAST)) THEN
         RETURN
      END IF

C     Otherwise read the data (height of the top of the grid cells)

      IF (.NOT. READ3(FILE, VNAME, ALLAYS3, JDATE, JTIME, DZ_GRID)) THEN
         MSG = "Could not read " // TRIM(VNAME) // " data from " // FILE
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

C     Calculate the width of the vertical layers

      DO I1 = 1, DIM1
         DO I2 = 1, DIM2
            DO I3 = DIM3, 2, -1
               DZ_GRID(I1, I2, I3) = DZ_GRID(I1, I2, I3) -
     &                               DZ_GRID(I1, I2, I3-1)
            END DO
         END DO
      END DO

C     Save the information about what data we just read

      JDATE_LAST = JDATE
      JTIME_LAST = JTIME

      END SUBROUTINE GET_DZ_GRID

C     ==================================================================

      SUBROUTINE GET_DZ_BDY(JDATE, JTIME)

C     This subroutine fetches the width of vertical layers at date JDATE
C     and time JTIME on the boundary. The result is returned in m.

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_DZ_BDY"
      CHARACTER(LEN=LEN_LOGICAL_NAME), PARAMETER :: FILE = "METBDY3D"
      CHARACTER(LEN=LEN_VNAME), PARAMETER :: VNAME = "ZF"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      INTEGER, SAVE :: DIM1, DIM2, DIM3,
     &                 JDATE_LAST = -1, JTIME_LAST = -1
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: STATUS, I1, I2, I3

C     ---  External function

      INTEGER, EXTERNAL :: INDEX1

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

C     Allocate the array that will store the data

         CALL GET_DIMS(FILE_CAT(FILE), DIM1, DIM2, DIM3)
         ALLOCATE(DZ_BDY(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "DZ_BDY memory allocation failed"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

C     Open the file to read

         IF (.NOT. OPEN3(FILE, FSREAD3, PNAME)) THEN
            MSG = "Could not open " // FILE // " (read-only)"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

C     Unit check

         IF (.NOT. DESC3(FILE)) THEN
            MSG = "Could not get description of " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         I1 = INDEX1(TRIM(VNAME), NVARS3D, VNAME3D)
         IF (I1 .EQ. 0) THEN
            MSG = "Variable " // TRIM(VNAME) // " not found in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         IF ((TRIM(UNITS3D(I1)) .NE. "m") .AND.
     &       (TRIM(UNITS3D(I1)) .NE. "M")) THEN
            MSG = "Bad units (" // TRIM(UNITS3D(I1)) //
     &            ") for " // TRIM(VNAME) // " in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

         FIRSTTIME = .FALSE.
      END IF

C     Nothing to do if we are reading the same quantity as last time

      IF ((JDATE .EQ. JDATE_LAST) .AND. (JTIME .EQ. JTIME_LAST)) THEN
         RETURN
      END IF

C     Otherwise read the data (height of the top of the grid cells)

      IF (.NOT. READ3(FILE, VNAME, ALLAYS3, JDATE, JTIME, DZ_BDY)) THEN
         MSG = "Could not read " // TRIM(VNAME) // " data from " // FILE
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

C     Calculate the width of the vertical layers

      DO I1 = 1, DIM1
         DO I2 = DIM2, 2, -1
            DO I3 = 1, DIM3
               DZ_BDY(I1, I2, I3) = DZ_BDY(I1, I2, I3) -
     &                              DZ_BDY(I1, I2-1, I3)
            END DO
         END DO
      END DO

C     Save the information about what data we just read

      JDATE_LAST = JDATE
      JTIME_LAST = JTIME

      END SUBROUTINE GET_DZ_BDY

C     ==================================================================

      SUBROUTINE GET_PRES_BDY(JDATE, JTIME)

C     This subroutine fetches the air pressure at date JDATE and time
C     JTIME on the boundary. The result is returned in Pa.

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_PRES_BDY"
      CHARACTER(LEN=LEN_LOGICAL_NAME), PARAMETER :: FILE = "METBDY3D"
      CHARACTER(LEN=LEN_VNAME), PARAMETER :: VNAME = "PRES"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      INTEGER, SAVE :: JDATE_LAST = -1, JTIME_LAST = -1
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: STATUS, DIM1, DIM2, DIM3, I

C     ---  External function

      INTEGER, EXTERNAL :: INDEX1

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

C     Allocate the array that will store the data

         CALL GET_DIMS(FILE_CAT(FILE), DIM1, DIM2, DIM3)
         ALLOCATE(PRES_BDY(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "PRES_BDY memory allocation failed"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

C     Open the file to read

         IF (.NOT. OPEN3(FILE, FSREAD3, PNAME)) THEN
            MSG = "Could not open " // FILE // " (read-only)"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

C     Unit check

         IF (.NOT. DESC3(FILE)) THEN
            MSG = "Could not get description of " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         I = INDEX1(TRIM(VNAME), NVARS3D, VNAME3D)
         IF (I .EQ. 0) THEN
            MSG = "Variable " // TRIM(VNAME) // " not found in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         IF (TRIM(UNITS3D(I)) .NE. "Pa") THEN
            MSG = "Bad units (" // TRIM(UNITS3D(I)) //
     &            ") for " // TRIM(VNAME) // " in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

         FIRSTTIME = .FALSE.
      END IF

C     Nothing to do if we are reading the same quantity as last time

      IF ((JDATE .EQ. JDATE_LAST) .AND. (JTIME .EQ. JTIME_LAST)) THEN
         RETURN
      END IF

C     Otherwise read the data

      IF (.NOT. READ3(FILE, VNAME, ALLAYS3, JDATE, JTIME, PRES_BDY)) THEN
         MSG = "Could not read " // TRIM(VNAME) // " data from " // FILE
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

C     Save the information about what data we just read

      JDATE_LAST = JDATE
      JTIME_LAST = JTIME

      END SUBROUTINE GET_PRES_BDY

C     ==================================================================

      SUBROUTINE GET_TA_BDY(JDATE, JTIME)

C     This subroutine fetches the air temperature at date JDATE and time
C     JTIME on the boundary. The result is returned in K.

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_TA_BDY"
      CHARACTER(LEN=LEN_LOGICAL_NAME), PARAMETER :: FILE = "METBDY3D"
      CHARACTER(LEN=LEN_VNAME), PARAMETER :: VNAME = "TA"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      INTEGER, SAVE :: JDATE_LAST = -1, JTIME_LAST = -1
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: STATUS, DIM1, DIM2, DIM3, I

C     ---  External function

      INTEGER, EXTERNAL :: INDEX1

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

C     Allocate the array that will store the data

         CALL GET_DIMS(FILE_CAT(FILE), DIM1, DIM2, DIM3)
         ALLOCATE(TA_BDY(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "TA_BDY memory allocation failed"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

C     Open the file to read

         IF (.NOT. OPEN3(FILE, FSREAD3, PNAME)) THEN
            MSG = "Could not open " // FILE // " (read-only)"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

C     Unit check

         IF (.NOT. DESC3(FILE)) THEN
            MSG = "Could not get description of " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         I = INDEX1(TRIM(VNAME), NVARS3D, VNAME3D)
         IF (I .EQ. 0) THEN
            MSG = "Variable " // TRIM(VNAME) // " not found in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         IF (TRIM(UNITS3D(I)) .NE. "K") THEN
            MSG = "Bad units (" // TRIM(UNITS3D(I)) //
     &            ") for " // TRIM(VNAME) // " in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

         FIRSTTIME = .FALSE.
      END IF

C     Nothing to do if we are reading the same quantity as last time

      IF ((JDATE .EQ. JDATE_LAST) .AND. (JTIME .EQ. JTIME_LAST)) THEN
         RETURN
      END IF

C     Otherwise read the data

      IF (.NOT. READ3(FILE, VNAME, ALLAYS3, JDATE, JTIME, TA_BDY)) THEN
         MSG = "Could not read " // TRIM(VNAME) // " data from " // FILE
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

C     Save the information about what data we just read

      JDATE_LAST = JDATE
      JTIME_LAST = JTIME

      END SUBROUTINE GET_TA_BDY

C     ==================================================================

      SUBROUTINE GET_PRES_GRID(JDATE, JTIME)

C     This subroutine fetches the air pressure at date JDATE and time
C     JTIME on the main grid. The result is returned in Pa.

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_PRES_GRID"
      CHARACTER(LEN=LEN_LOGICAL_NAME), PARAMETER :: FILE = "METCRO3D"
      CHARACTER(LEN=LEN_VNAME), PARAMETER :: VNAME = "PRES"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      INTEGER, SAVE :: JDATE_LAST = -1, JTIME_LAST = -1
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: STATUS, DIM1, DIM2, DIM3, I

C     ---  External function

      INTEGER, EXTERNAL :: INDEX1

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

C     Allocate the array that will store the data

         CALL GET_DIMS(FILE_CAT(FILE), DIM1, DIM2, DIM3)
         ALLOCATE(PRES_GRID(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "PRES_GRID memory allocation failed"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

C     Open the file to read

         IF (.NOT. OPEN3(FILE, FSREAD3, PNAME)) THEN
            MSG = "Could not open " // FILE // " (read-only)"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

C     Unit check

         IF (.NOT. DESC3(FILE)) THEN
            MSG = "Could not get description of " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         I = INDEX1(TRIM(VNAME), NVARS3D, VNAME3D)
         IF (I .EQ. 0) THEN
            MSG = "Variable " // TRIM(VNAME) // " not found in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         IF ((TRIM(UNITS3D(I)) .NE. "Pa")) THEN
            MSG = "Bad units (" // TRIM(UNITS3D(I)) //
     &            ") for " // TRIM(VNAME) // " in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

         FIRSTTIME = .FALSE.
      END IF

C     Nothing to do if we are reading the same quantity as last time

      IF ((JDATE .EQ. JDATE_LAST) .AND. (JTIME .EQ. JTIME_LAST)) THEN
         RETURN
      END IF

C     Otherwise read the data

      IF (.NOT. READ3(FILE, VNAME, ALLAYS3, JDATE, JTIME, PRES_GRID)) THEN
         MSG = "Could not read " // TRIM(VNAME) // " data from " // FILE
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

C     Save the information about what data we just read

      JDATE_LAST = JDATE
      JTIME_LAST = JTIME

      END SUBROUTINE GET_PRES_GRID

C     ==================================================================

      SUBROUTINE GET_TA_GRID(JDATE, JTIME)

C     This subroutine fetches the air temperature at date JDATE and time
C     JTIME on the main grid. The result is returned in K.

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "GET_TA_GRID"
      CHARACTER(LEN=LEN_LOGICAL_NAME), PARAMETER :: FILE = "METCRO3D"
      CHARACTER(LEN=LEN_VNAME), PARAMETER :: VNAME = "TA"
      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      INTEGER, SAVE :: JDATE_LAST = -1, JTIME_LAST = -1
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: STATUS, DIM1, DIM2, DIM3, I

C     ---  External function

      INTEGER, EXTERNAL :: INDEX1

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

C     Allocate the array that will store the data

         CALL GET_DIMS(FILE_CAT(FILE), DIM1, DIM2, DIM3)
         ALLOCATE(TA_GRID(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "TA_GRID memory allocation failed"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

C     Open the file to read

         IF (.NOT. OPEN3(FILE, FSREAD3, PNAME)) THEN
            MSG = "Could not open " // FILE // " (read-only)"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

C     Unit check

         IF (.NOT. DESC3(FILE)) THEN
            MSG = "Could not get description of " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         I = INDEX1(TRIM(VNAME), NVARS3D, VNAME3D)
         IF (I .EQ. 0) THEN
            MSG = "Variable " // TRIM(VNAME) // " not found in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         IF ((TRIM(UNITS3D(I)) .NE. "K")) THEN
            MSG = "Bad units (" // TRIM(UNITS3D(I)) //
     &            ") for " // TRIM(VNAME) // " in " // FILE
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

         FIRSTTIME = .FALSE.
      END IF

C     Nothing to do if we are reading the same quantity as last time

      IF ((JDATE .EQ. JDATE_LAST) .AND. (JTIME .EQ. JTIME_LAST)) THEN
         RETURN
      END IF

C     Otherwise read the data

      IF (.NOT. READ3(FILE, VNAME, ALLAYS3, JDATE, JTIME, TA_GRID)) THEN
         MSG = "Could not read " // TRIM(VNAME) // " data from " // FILE
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

C     Save the information about what data we just read

      JDATE_LAST = JDATE
      JTIME_LAST = JTIME

      END SUBROUTINE GET_TA_GRID

C     ==================================================================

      SUBROUTINE CHECK_PERT_TYPE(PERT_TYPE, PNAME, JDATE, JTIME)

C     This subroutine calls M3EXIT if PERT_TYPE is not a valid
C     perturbation type.

      IMPLICIT NONE

C     --- Arguments

      CHARACTER(LEN=LEN_PERT_TYPE), INTENT(IN) :: PERT_TYPE
      CHARACTER(LEN=LEN_PNAME), INTENT(IN) :: PNAME
      INTEGER, INTENT(IN) :: JDATE, JTIME

C     --- Local variables

      CHARACTER(LEN=LEN_MSG) :: MSG

C     ------------------------------------------------------------------

      IF ((PERT_TYPE .NE. "ADD") .AND. (PERT_TYPE .NE. "MUL")) THEN
         MSG = "Wrong perturbation type: " // PERT_TYPE
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

      END SUBROUTINE CHECK_PERT_TYPE

C     ==================================================================

      SUBROUTINE SENS_INDIV(JDATE, JTIME, SENS_TYPE, SPC, PERT_TYPE,
     &                      I_INFILE, SENS)

C     This subroutine calculates the sensitivity of type SENS_TYPE for
C     species SPC at date JDATE and time JTIME. SPC cannot be a species
C     category.

      IMPLICIT NONE

C     ---  Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME, I_INFILE
      CHARACTER(LEN=LEN_SENS_TYPE), INTENT(IN) :: SENS_TYPE
      CHARACTER(LEN=LEN_VNAME), INTENT(IN) :: SPC
      CHARACTER(LEN=LEN_PERT_TYPE) :: PERT_TYPE
      REAL, INTENT(OUT) :: SENS(:,:,:)

C     ---  Local variables

      LOGICAL, SAVE :: FIRSTTIME = .TRUE.
      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "SENS_INDIV"
      REAL, SAVE :: DTSEC
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: CAT, DIM1, DIM2, DIM3, I1, I2, I3, LAYERS
      REAL, ALLOCATABLE :: TEMP(:,:,:)

C     --- External functions

      INTEGER, EXTERNAL :: TIME2SEC

C     ------------------------------------------------------------------

      IF (FIRSTTIME) THEN

         DTSEC = FLOAT(TIME2SEC(TSTEP))

         FIRSTTIME = .FALSE.

      END IF

      CALL CHECK_PERT_TYPE(PERT_TYPE, PNAME, JDATE, JTIME)

      CAT = ST_TO_CAT(SENS_TYPE)

      CALL GET_DIMS(CAT, DIM1, DIM2, DIM3)

C     Check the size of the input array

      IF ((SIZE(SENS, DIM=1) .NE. DIM1) .OR.
     &    (SIZE(SENS, DIM=2) .NE. DIM2) .OR.
     &    (SIZE(SENS, DIM=3) .NE. DIM3)) THEN
         MSG = "Array argument has the wrong size"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

C     Get the adjoint variable

      CALL GET_ADJ_GRID(JDATE, JTIME, SPC)

C     Sensitivity to boundary conditions

      IF (SENS_TYPE .EQ. "BC") THEN

         CALL GET_DZ_BDY(JDATE, JTIME)
         CALL GET_INFLOW_BDY(JDATE, JTIME)
         CALL GET_ADJ_BDY(JDATE, JTIME, SPC)

         IF (PERT_TYPE .EQ. "MUL") THEN
            CALL GET_BC_BDY(JDATE, JTIME, SPC, I_INFILE)
         END IF

         DO I1 = 1, DIM1
            DO I2 = 1, DIM2
               DO I3 = 1, DIM3
                  SENS(I1, I2, I3) = ADJ_BDY(I1, I2, I3) *
     &                               INFLOW_BDY(I1, I2, I3) *
     &                               DZ_BDY(I1, I2, I3) * DTSEC
                  IF (PERT_TYPE .EQ. "MUL") THEN
                     SENS(I1, I2, I3) = SENS(I1, I2, I3) * BC_BDY(I1, I2, I3)
                  END IF
               END DO
            END DO
         END DO

C     Sensitivity to initial conditions

      ELSE IF (SENS_TYPE .EQ. "IC") THEN

         CALL GET_DZ_GRID(JDATE, JTIME)

         IF (PERT_TYPE .EQ. "MUL") THEN
            CALL GET_IC_GRID(JDATE, JTIME, SPC, I_INFILE)
         END IF

         DO I1 = 1, DIM1
            DO I2 = 1, DIM2
               DO I3 = 1, DIM3
                  SENS(I1, I2, I3) = ADJ_GRID(I1, I2, I3) * XCELL(CAT) *
     &                               YCELL(CAT) * DZ_GRID(I1, I2, I3)
                  IF (PERT_TYPE .EQ. "MUL") THEN
                     SENS(I1, I2, I3) = SENS(I1, I2, I3) * IC_GRID(I1, I2, I3)
                  END IF
               END DO
            END DO
         END DO

C     Sensitivity to emissions

      ELSE IF (SENS_TYPE .EQ. "EM") THEN

         IF (PERT_TYPE .EQ. "MUL") THEN
            CALL GET_EM_GRID(JDATE, JTIME, SPC, I_INFILE)
         END IF

         DO I1 = 1, DIM1
            DO I2 = 1, DIM2
               DO I3 = 1, DIM3
                     SENS(I1, I2, I3) = ADJ_GRID(I1, I2, I3) * XCELL(CAT) *
     &                                  YCELL(CAT) * DTSEC
                  IF (PERT_TYPE .EQ. "MUL") THEN
                     SENS(I1, I2, I3) = SENS(I1, I2, I3) * EM_GRID(I1, I2, I3)
                  END IF
               END DO
            END DO
         END DO

      ELSE

         MSG = "Unknown sensitivity type: " // SENS_TYPE
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)

      END IF

      END SUBROUTINE SENS_INDIV

C     ==================================================================

      SUBROUTINE SENS_SPCCAT(JDATE, JTIME, SENS_TYPE, SPCCAT, PERT_TYPE,
     &                       I_INFILE, SENS)

C     This subroutine calculates the sensitivity of type SENS_TYPE for
C     category of species SPCCAT at date JDATE and time JTIME.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL

C     --- Arguments

      INTEGER, INTENT(IN) :: JDATE, JTIME, I_INFILE
      CHARACTER(LEN=LEN_SENS_TYPE), INTENT(IN) :: SENS_TYPE
      CHARACTER(LEN=LEN_VNAME), INTENT(IN) :: SPCCAT
      CHARACTER(LEN=LEN_PERT_TYPE), INTENT(IN) :: PERT_TYPE
      REAL, INTENT(OUT) :: SENS(:,:,:)

C     --- Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "SENS_IC_ADD"
      CHARACTER(LEN=LEN_MSG) :: MSG
      CHARACTER(LEN=LEN_VNAME) :: SPC
      INTEGER :: STATUS, CAT, DIM1, DIM2, DIM3,
     &           I_ST, I_SPCCAT, I_SPC, I1, I2, I3
      REAL :: FACTOR
      REAL, ALLOCATABLE :: TEMP(:,:,:)

C     ------------------------------------------------------------------

      CALL CHECK_PERT_TYPE(PERT_TYPE, PNAME, JDATE, JTIME)

C     Check the size of the input array

      CAT = ST_TO_CAT(SENS_TYPE)
      CALL GET_DIMS(CAT, DIM1, DIM2, DIM3)

      IF ((SIZE(SENS, DIM=1) .NE. DIM1) .OR.
     &    (SIZE(SENS, DIM=2) .NE. DIM2) .OR.
     &    (SIZE(SENS, DIM=3) .NE. DIM3)) THEN
         MSG = "Array argument has the wrong size"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

C     Allocate temporary array

      ALLOCATE(TEMP(DIM1, DIM2, DIM3), STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "TEMP memory allocation failed"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

C     Calculate the sensitivity to the species category

      I_SPCCAT = INDEX_SPCCAT(SPCCAT)
      I_ST = INDEX_SENS_TYPE(SENS_TYPE)
      SENS = 0.

      DO I_SPC = 1, N_SPCSINCAT(I_SPCCAT)

         SPC = SPCSINCAT(I_SPCCAT, I_SPC)

         CALL SENS_INDIV(JDATE, JTIME, SENS_TYPE, SPC, PERT_TYPE,
     &                   I_INFILE, TEMP)

         IF (PERT_TYPE .EQ. "ADD") THEN
            FACTOR = WGT_SPCCAT(I_SPCCAT, I_ST, I_INFILE, I_SPC)
         ELSE
            FACTOR = 1.
         END IF

         DO I1 = 1, DIM1
            DO I2 = 1, DIM2
               DO I3 = 1, DIM3
                  SENS(I1, I2, I3) = SENS(I1, I2, I3) +
     &                               TEMP(I1, I2, I3) * FACTOR
               END DO
            END DO
         END DO

      END DO

C     Deallocate temporary array

      DEALLOCATE(TEMP, STAT=STATUS)
      IF (STATUS .NE. 0) THEN
         MSG = "TEMP memory deallocation failed"
         CALL M3WARN(PNAME, JDATE, JTIME, MSG)
      END IF

      END SUBROUTINE SENS_SPCCAT

C     ==================================================================

      SUBROUTINE TREAT_SENS(ST, VNAME, JDATE, JTIME, GRID)

C     This subroutine applies time treatments to sensitivity and write
C     the results to the correponding file.

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL

C     --- Arguments

      CHARACTER(LEN=LEN_SENS_TYPE) :: ST
      INTEGER, INTENT(IN) :: JDATE, JTIME
      CHARACTER(LEN=LEN_VNAME), INTENT(IN) :: VNAME
      REAL, INTENT(IN) :: GRID(:,:,:)

C     --- Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "TREAT_SENS"
      CHARACTER(LEN=LEN_MSG) :: MSG
      CHARACTER(LEN=LEN_LOGICAL_NAME) :: FILE
      INTEGER :: STATUS, CAT, DIM1, DIM2, DIM3,
     &           I_ST, I_TREAT, I1, I2, I3
      REAL :: FACTOR
      REAL, ALLOCATABLE :: TEMP(:,:,:)

C     ------------------------------------------------------------------

C     Check the size of the input array

      CAT = ST_TO_CAT(ST)
      CALL GET_DIMS(CAT, DIM1, DIM2, DIM3)

      IF ((SIZE(GRID, DIM=1) .NE. DIM1) .OR.
     &    (SIZE(GRID, DIM=2) .NE. DIM2) .OR.
     &    (SIZE(GRID, DIM=3) .NE. DIM3)) THEN
         MSG = "Array argument has the wrong size"
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
      END IF

C     Apply each treatment

      I_ST = INDEX_SENS_TYPE(ST)

      DO I_TREAT = 1, N_TREATMENTS(I_ST)

         FILE = "OUTFILE_" // ST // "_" // TREATMENTS(I_ST, I_TREAT)

C     If no treatment then just write to file

         IF (TRIM(TREATMENTS(I_ST, I_TREAT)) .EQ. "NONE") THEN

            IF (.NOT. WRITE3(FILE, VNAME, JDATE, JTIME, GRID)) THEN
               MSG = "Could not write " // VNAME // " to " // FILE
               CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
            END IF

            CYCLE

         END IF

C     Otherwise we are going to need a temporary array

         IF (.NOT. ALLOCATED(TEMP)) THEN
            ALLOCATE(TEMP(DIM1, DIM2, DIM3), STAT=STATUS)
            IF (STATUS .NE. 0) THEN
               MSG = "TEMP memory allocation failed"
               CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
            END IF
         END IF

C     If we are processing the start date and time, then initialize the
C     temporary array to zero. Otherwise, read the existing data

         IF ((JDATE .EQ. SDATE) .AND. (JTIME .EQ. STIME)) THEN

            TEMP = 0.

         ELSE

            IF (.NOT. READ3(FILE, VNAME, ALLAYS3, SDATE, STIME, TEMP)) THEN
               MSG = "Could not read " // TRIM(VNAME) // " from " //FILE
               CALL M3EXIT(PNAME, SDATE, STIME, MSG, XSTAT1)
            END IF

         END IF

C     Multiplicative factor depends on treatment and sensitivity type

         IF (ST .EQ. "IC") THEN
            FACTOR = 1.
         ELSE IF (TRIM(TREATMENTS(I_ST, I_TREAT)) .EQ. "SUM") THEN
            FACTOR = 1.
         ELSE IF (TRIM(TREATMENTS(I_ST, I_TREAT)) .EQ. "MEAN") THEN
            FACTOR = 1. / FLOAT(N_TSTEPS)
         ELSE
            MSG = "Unknown treatment: " // TREATMENTS(I_ST, I_TREAT)
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

C     Apply the treatment

         DO I1 = 1, DIM1
            DO I2 = 1, DIM2
               DO I3 = 1, DIM3
                  TEMP(I1, I2, I3) = TEMP(I1, I2, I3) +
     &                               GRID(I1, I2, I3) * FACTOR
               END DO
            END DO
         END DO

C     Write the updated data to file

         IF (.NOT. WRITE3(FILE, VNAME, SDATE, STIME, TEMP)) THEN
            MSG = "Could not write " // VNAME // " to " // FILE
            CALL M3EXIT(PNAME, SDATE, STIME, MSG, XSTAT1)
         END IF

      END DO

C     Deallocate temporary local array if it has been allocated

      IF (ALLOCATED(TEMP)) THEN
         DEALLOCATE(TEMP, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "TEMP memory deallocation failed"
            CALL M3WARN(PNAME, JDATE, JTIME, MSG)
         END IF
      END IF

      END SUBROUTINE TREAT_SENS

C     ==================================================================

      SUBROUTINE INDICES_BDY(BDY, IDX_START, IDX_END)

C     This subroutine calculates the starting and ending indices of a
C     boundary along the PERIM dimension of a boundary file.

      IMPLICIT NONE

C     --- Arguments

      CHARACTER(LEN=LEN_BDY), INTENT(IN) :: BDY
      INTEGER, INTENT(OUT) :: IDX_START, IDX_END

C     --- Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "INDICES_BDY"
      INTEGER, PARAMETER :: CAT = 3
      CHARACTER(LEN=LEN_MSG) :: MSG

C     ------------------------------------------------------------------

      IF (NTHIK(CAT) .NE. 1) THEN
         MSG = "NTHIK non-equal to 1 not supported"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      IF (BDY .EQ. "N") THEN
         IDX_START = NCOLS(CAT) + NROWS(CAT) + 4
         IDX_END = IDX_START + NCOLS(CAT) - 1
      ELSE IF (BDY .EQ. "S") THEN
         IDX_START = 1
         IDX_END = IDX_START + NCOLS(CAT) - 1
      ELSE IF (BDY .EQ. "E") THEN
         IDX_START = NCOLS(CAT) + 2
         IDX_END = IDX_START + NROWS(CAT) - 1
      ELSE IF (BDY .EQ. "W") THEN
         IDX_START = 2*NCOLS(CAT) + NROWS(CAT) + 5
         IDX_END = IDX_START + NROWS(CAT) - 1
      ELSE
         MSG = "Unknown boundary: " // BDY
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      END SUBROUTINE INDICES_BDY

C     ==================================================================

      END MODULE ADJPOST_MODULE
