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
C     This file is part of the CMAQ-v4.5-ADJ post processor.
C
C     This file is the main program.

      PROGRAM ADJPOST

      USE ADJPOST_MODULE

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "ADJPOST"
      CHARACTER(LEN=LEN_MSG) :: MSG
      CHARACTER(LEN=LEN_LOGICAL_NAME) :: FILE
      CHARACTER(LEN=LEN_NICKNAME) :: NICKNAME
      CHARACTER(LEN=LEN_SENS_TYPE) :: ST
      CHARACTER(LEN=LEN_VNAME) :: SPC, VNAME
      INTEGER :: LOG, STATUS, JDATE, JTIME, CAT, DIM1, DIM2, DIM3,
     &           I_INFILE, I_TSTEP, I_ST, I_SPC, I1, I2, I3
      REAL, ALLOCATABLE :: GRID(:,:,:)

C     ------------------------------------------------------------------

C     ----------
C     Initialize
C     ----------

      CALL GIT_VERBOSE()

      LOG = INIT3()

      WRITE(LOG, '(5X, A)') "*********************************************"
      WRITE(LOG, '(5X, A)') "* ADJPOST, post-processor for CMAQ-v4.5-ADJ *"
      WRITE(LOG, '(5X, A)') "*********************************************"

      CALL INITIALIZE()

C     -----------------------
C     Calculate sensitivities
C     -----------------------

      DO I_ST = 1, N_SENS_TYPES

C     If the list of species (including species categories) or the list
C     of treatments to apply is empty, then there is nothing to do for
C     this sensitivity type

         IF ((N_SPECIES(I_ST) + N_SPCCATS(I_ST) .EQ. 0) .OR.
     &       (N_TREATMENTS(I_ST) .EQ. 0)) THEN
            CYCLE
         END IF

         ST = SENSITIVITY_TYPES(I_ST)
         CAT = ST_TO_CAT(ST)
         CALL GET_DIMS(CAT, DIM1, DIM2, DIM3)

         ALLOCATE(GRID(DIM1, DIM2, DIM3), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "GRID memory allocation failed"
            CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
         END IF

         JDATE = SDATE
         JTIME = STIME

         DO I_TSTEP = 1, N_TSTEPS

C     Sensitivity to initial conditions are only calculated for the
C     start date/time

            IF ((ST .EQ. "IC") .AND. ((JDATE .NE. SDATE) .OR.
     &                                (JTIME .NE. STIME))) THEN
               CYCLE
            END IF

            DO I_SPC = 1, N_SPECIES(I_ST)+N_SPCCATS(I_ST)

C     Additive sensitivity

               SPC = SPECIES(I_ST, I_SPC)

               IF (I_SPC .LE. N_SPECIES(I_ST)) THEN
                  CALL SENS_INDIV(JDATE, JTIME, ST, SPC, "ADD", 0, GRID)
               ELSE
                  CALL SENS_SPCCAT(JDATE, JTIME, ST, SPC, "ADD", 0, GRID)
               END IF

               VNAME = TRIM(SPC) // "-add"
               CALL TREAT_SENS(ST, VNAME, JDATE, JTIME, GRID)

               DO I_INFILE = 1, N_INFILES(I_ST)

                  NICKNAME = NICKNAMES(I_ST, I_INFILE)

C     Additive sensitivity to species category with input file

                  IF (I_SPC .GT. N_SPECIES(I_ST)) THEN

                     CALL SENS_SPCCAT(JDATE, JTIME, ST, SPC, "ADD",
     &                                I_INFILE, GRID)
                     VNAME = TRIM(SPC) // "-add-" // TRIM(NICKNAME)
                     CALL TREAT_SENS(ST, VNAME, JDATE, JTIME, GRID)

                  END IF

C     Multiplicative sensitivity

                  IF (I_SPC .LE. N_SPECIES(I_ST)) THEN
                     CALL SENS_INDIV(JDATE, JTIME, ST, SPC, "MUL",
     &                               I_INFILE, GRID)
                  ELSE
                     CALL SENS_SPCCAT(JDATE, JTIME, ST, SPC, "MUL",
     &                                I_INFILE, GRID)
                  END IF

                  VNAME = TRIM(SPC) // "-mul-" // TRIM(NICKNAME)
                  CALL TREAT_SENS(ST, VNAME, JDATE, JTIME, GRID)

               END DO

            END DO

            CALL NEXTIME(JDATE, JTIME, TSTEP)

         END DO

         DEALLOCATE(GRID, STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "GRID memory deallocation failed"
            CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
         END IF

      END DO

C     --------
C     Finalize
C     --------

      CALL FINALIZE()

      WRITE(LOG, '(A)') ""
      WRITE(LOG, '(5X, A)') "*********************************"
      WRITE(LOG, '(5X, A)') "* ADJPOST, succesful completion *"
      WRITE(LOG, '(5X, A)') "*********************************"
      WRITE(LOG, '(A)') ""

      END PROGRAM ADJPOST
