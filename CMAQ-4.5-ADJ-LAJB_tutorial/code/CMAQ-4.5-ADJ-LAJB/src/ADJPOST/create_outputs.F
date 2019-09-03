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
C     This file contains the subroutine that creates output files.

      SUBROUTINE CREATE_OUTPUTS()

      USE ADJPOST_MODULE

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IOFDESC
      INCLUDE SUBST_IODECL

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "CREATE_OUTPUTS"
      CHARACTER(LEN=LEN_MSG) :: MSG
      CHARACTER(LEN=LEN_LOGICAL_NAME) :: FILE
      CHARACTER(LEN=LEN_SENS_TYPE) :: ST
      CHARACTER(LEN=LEN_TREATMENT) :: TREATMENT
      INTEGER :: CAT, I_ST, I_TREAT, I_SPC, I, J

C     --- External functions

      CHARACTER(LEN=LEN_UNITS) :: SENS_UNITS

C     ------------------------------------------------------------------

      DO I_ST = 1, N_SENS_TYPES

         ST = SENSITIVITY_TYPES(I_ST)

         DO I_TREAT = 1, N_TREATMENTS(I_ST)

            TREATMENT = TREATMENTS(I_ST, I_TREAT)

            FILE = "OUTFILE_" // ST // "_" // TREATMENT
            CAT = FILE_CAT(FILE)

            IF (FILE_CAT_FIRST(CAT)) THEN
               WRITE(MSG, '(A, I1, A)') "Category ", CAT,
     &                                  " has not been initialized"
               CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
            END IF

C     Set the parameters other than the ones related to variables

            FTYPE3D = FTYPE(CAT)
            SDATE3D = SDATE
            STIME3D = STIME
            IF ((TRIM(TREATMENT) .EQ. "NONE") .AND. (ST .NE. "IC")) THEN
               TSTEP3D = TSTEP
            ELSE
               TSTEP3D = 0
            END IF
            NCOLS3D = NCOLS(CAT)
            NROWS3D = NROWS(CAT)
            NLAYS3D = NLAYS(CAT)
            NTHIK3D = NTHIK(CAT)
            GDTYP3D = GDTYP(CAT)
            P_ALP3D = P_ALP(CAT)
            P_BET3D = P_BET(CAT)
            P_GAM3D = P_GAM(CAT)
            XCENT3D = XCENT(CAT)
            YCENT3D = YCENT(CAT)
            XORIG3D = XORIG(CAT)
            YORIG3D = YORIG(CAT)
            XCELL3D = XCELL(CAT)
            YCELL3D = YCELL(CAT)
            VGTYP3D = VGTYP(CAT)
            VGTOP3D = VGTOP(CAT)
            DO I = 1, NLAYS3D + 1
               VGLVS3D(I) = VGLVS(CAT, I)
            END DO
            GDNAM3D = GRIDNAME
            FDESC3D(1) = "Adjoint sensitivities to " //
     &                   SENSITIVITY_TYPES_LONG(I_ST)
            IF (TREATMENT .EQ. "NONE") THEN
               FDESC3D(2) = "No time treatment"
            ELSE IF (TREATMENT .EQ. "MEAN") THEN
               FDESC3D(2) = "Time average"
            ELSE IF (TREATMENT .EQ. "SUM") THEN
               FDESC3D(2) = "Sum along time"
            ELSE
               MSG = "Unknown treatment: " // TREATMENT
               CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
            END IF

C     Set the parameters related to variables

            NVARS3D = N_SPECIES(I_ST) * (1+N_INFILES(I_ST)) +
     &                N_SPCCATS(I_ST) * (1+2*N_INFILES(I_ST))
            IF (NVARS3D .GT. MXVARS3) THEN
               WRITE(MSG, '(A, I4, A, I4, A)') "Too many variables: ",
     &              NVARS3D, " (max: ", MXVARS3, ")"
               CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
            END IF

            I_SPC = 0

            DO I = 1, N_SPECIES(I_ST)+N_SPCCATS(I_ST)

               I_SPC = I_SPC + 1
               VTYPE3D(I_SPC) = M3REAL
               VNAME3D(I_SPC) = TRIM(SPECIES(I_ST, I)) // "-add"
               UNITS3D(I_SPC) = SENS_UNITS(ST, "ADD")
               VDESC3D(I_SPC) = "Additive sensitivity to " //
     &                          TRIM(SPECIES(I_ST, I))

               DO J = 1, N_INFILES(I_ST)

                  IF (I .GT. N_SPECIES(I_ST)) THEN
                     I_SPC = I_SPC + 1
                     VTYPE3D(I_SPC) = M3REAL
                     VNAME3D(I_SPC) = TRIM(SPECIES(I_ST, I)) //
     &                                "-add-" // TRIM(NICKNAMES(I_ST, J))
                     UNITS3D(I_SPC) =  SENS_UNITS(ST, "ADD")
                     VDESC3D(I_SPC) = "Additive sensitivity to " //
     &                                TRIM(SPECIES(I_ST, I)) // " (" //
     &                                TRIM(NICKNAMES(I_ST, J)) // ")"
                  END IF

                  I_SPC = I_SPC + 1
                  VTYPE3D(I_SPC) = VTYPE3D(I)
                  VNAME3D(I_SPC) = TRIM(SPECIES(I_ST, I)) // "-mul-" //
     &                             TRIM(NICKNAMES(I_ST, J))
                  UNITS3D(I_SPC) = SENS_UNITS(ST, "MUL")
                  VDESC3D(I_SPC) = "Multiplicative sensitivity to " //
     &                             TRIM(SPECIES(I_ST, I)) // " (" //
     &                             TRIM(NICKNAMES(I_ST, J)) // ")"
               END DO

            END DO

            IF (I_SPC .NE. NVARS3D) THEN
               MSG="Problem with number of variables"
               CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
            END IF

            IF (.NOT. OPEN3(FILE, FSNEW3, PNAME)) THEN
               MSG = "Could not create " // FILE
               CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
            END IF

         END DO

      END DO

      END SUBROUTINE CREATE_OUTPUTS

C     ==================================================================

      CHARACTER(LEN=LEN_UNITS) FUNCTION SENS_UNITS(SENS_TYPE, PERT_TYPE)

C     Get units for sensitivity type SENS_TYPE and perturbation type
C     PERT_TYPE

      USE ADJPOST_MODULE

      IMPLICIT NONE

C     --- Arguments

      CHARACTER(LEN=LEN_SENS_TYPE), INTENT(IN) :: SENS_TYPE
      CHARACTER(LEN=LEN_PERT_TYPE), INTENT(IN) :: PERT_TYPE

C     --- Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "SENS_UNITS"
      CHARACTER(LEN=LEN_MSG) :: MSG

C     ------------------------------------------------------------------

      CALL CHECK_PERT_TYPE(PERT_TYPE, PNAME, JDATE_NONE, JTIME_NONE)

      IF (PERT_TYPE .EQ. "ADD") THEN

         IF ((SENS_TYPE .EQ. "BC") .OR. (SENS_TYPE .EQ. "IC")) THEN
            SENS_UNITS = "{adj}*m**3"
         ELSE
            SENS_UNITS = "{adj}*s*m**2"
         END IF

      ELSE

         SENS_UNITS = "mol*{adj}"

      END IF

      END FUNCTION SENS_UNITS
