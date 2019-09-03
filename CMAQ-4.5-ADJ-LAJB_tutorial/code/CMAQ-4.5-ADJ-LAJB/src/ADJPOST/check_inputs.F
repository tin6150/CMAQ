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
C     This file contains the subroutine that check the consistency of
C     input files.

      SUBROUTINE CHECK_INPUTS()

C     This subroutine reads the header of each input file, and checks
C     whether the file descriptions are consistent across the different
C     files. The following parameters need to be consistent across all
C     files: NCOLS3D, NROWS3D, NTHIK3D, GDTYP3D, VGTYP3D, P_ALP3D,
C     P_BET3D, P_GAM3D, XCENT3D, YCENT3D, XORIG3D, YORIG3D, XCENT3D,
C     YCENT3D, VGTOP3D. Additionaly, the vertical layers (NLAYS3D and
C     VGLVS3D) must be consistent between files of category 1 and 3. If
C     file descriptions are not consistent across all files, M3EXIT is
C     called.
C
C     To clarify the implementation: each time CHECK_FILE is called, the
C     description of the file passed as its argument is checked against
C     the description of files of the same category. After CHECK_FILE
C     has been called on each input file, CHECK_INPUT checks the
C     consistency of file descriptions across file categories.

      USE ADJPOST_MODULE

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "CHECK_INPUTS"
      CHARACTER(LEN=LEN_MSG) :: MSG
      CHARACTER(LEN=LEN_LOGICAL_NAME) :: FILE
      INTEGER :: I, J, K

C     ------------------------------------------------------------------

      FILE = "METCRO3D"
      CALL CHECK_FILE(FILE)
      FILE = "METDOT3D"
      CALL CHECK_FILE(FILE)
      FILE = "METBDY3D"
      CALL CHECK_FILE(FILE)
      FILE = "INFILE_ADJ"
      CALL CHECK_FILE(FILE)
      DO I = 1, N_SENS_TYPES
         DO J = 1, N_INFILES(I)
            CALL CHECK_FILE(INFILES(I, J))
         END DO
      END DO

C     Get the first category for which a file was checked

      J = 1
      DO WHILE (FILE_CAT_FIRST(J) .AND. (J .LT. N_FILE_CATS))
         J = J +1
      END DO

C     Check consistency of file parameters across file categories

      IF (.NOT. FILE_CAT_FIRST(J)) THEN

         DO I = J+1, N_FILE_CATS
            IF (.NOT. FILE_CAT_FIRST(I)) THEN

C     These parameters must be common for all files

               IF ((NTHIK(I) .NE. NTHIK(J)) .OR.
     &             (GDTYP(I) .NE. GDTYP(J)) .OR.
     &             (P_ALP(I) .NE. P_ALP(J)) .OR.
     &             (P_BET(I) .NE. P_BET(J)) .OR.
     &             (P_GAM(I) .NE. P_GAM(J)) .OR.
     &             (XCENT(I) .NE. XCENT(J)) .OR.
     &             (YCENT(I) .NE. YCENT(J)) .OR.
     &             (XCELL(I) .NE. XCELL(J)) .OR.
     &             (YCELL(I) .NE. YCELL(J))) THEN
                  MSG = "Inconsistent cross-category parameters (1)"
                  CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
               END IF

C     A few parameters are different for the DOT files but we can still
C     check them versus the parameters of the other files

               IF (I .EQ. 4) THEN
                  IF ((NCOLS(I) .NE. NCOLS(J)+1) .OR.
     &                (NROWS(I) .NE. NROWS(J)+1) .OR.
     &                (XORIG(I) .NE. XORIG(J)-XCELL(J)/2.) .OR.
     &                (YORIG(I) .NE. YORIG(J)-YCELL(J)/2.)) THEN
                     MSG = "Inconsistent cross-category parameters (2)"
                     CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
                  END IF
               ELSE IF (J .EQ. 4) THEN
                  IF ((NCOLS(J) .NE. NCOLS(I)+1) .OR.
     &                (NROWS(J) .NE. NROWS(I)+1) .OR.
     &                (XORIG(J) .NE. XORIG(I)-XCELL(I)/2.) .OR.
     &                (YORIG(J) .NE. YORIG(I)-YCELL(I)/2.)) THEN
                     MSG = "Inconsistent cross-category parameters (3)"
                     CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
                  END IF
               ELSE
                  IF ((NCOLS(I) .NE. NCOLS(J)) .OR.
     &                (NROWS(I) .NE. NROWS(J)) .OR.
     &                (XORIG(I) .NE. XORIG(J)) .OR.
     &                (YORIG(I) .NE. YORIG(J))) THEN
                     MSG = "Inconsistent cross-category parameters (4)"
                     CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
                  END IF
               END IF

C     Vertical layers must be consistent for all files that are not flat

               IF ((I .NE. 2) .AND. (J .NE. 2)) THEN

                  IF ((VGTYP(I) .NE. VGTYP(J)) .OR.
     &                (VGTOP(I) .NE. VGTOP(J)) .OR.
     &                (NLAYS(I) .NE. NLAYS(J))) THEN
                     MSG = "Inconsistent cross-category parameters (5)"
                     CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
                  END IF

                  DO K = 1, NLAYS(I)+1
                     IF (VGLVS(I, K) .NE. VGLVS(J, K)) THEN
                        MSG = "Inconsistent cross-category parameters (6)"
                        CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
                     END IF
                  END DO

               END IF

            END IF
         END DO

      END IF

      END SUBROUTINE CHECK_INPUTS

C     ==================================================================

      SUBROUTINE CHECK_FILE(LOGICAL_NAME)

C     This subroutine reads the header of the input file defined by the
C     logical name LOGICAL_NAME. If files of the same category as
C     LOGICAL_NAME have already been checked with CHECK_FILE, then the
C     consistency of LOGICAL_NAME's file description is checked against
C     these files. If the descriptions are inconsistent, M3EXIT is
C     called. If LOGICAL_NAME is the first file of its category to be
C     checked by CHECK_FILE, then its description is saved so that other
C     files of the same category can be checked against this description
C     in the future.

      USE ADJPOST_MODULE

      IMPLICIT NONE

C     --- Include files

      INCLUDE SUBST_IODECL
      INCLUDE SUBST_IOFDESC

C     ---  Arguments

      CHARACTER(LEN=LEN_LOGICAL_NAME), INTENT(IN) :: LOGICAL_NAME

C     ---  Local variables

      CHARACTER(LEN=LEN_PNAME), PARAMETER :: PNAME = "CHECK_FILE"
      CHARACTER(LEN=LEN_MSG) :: MSG
      INTEGER :: CAT, I

C     ------------------------------------------------------------------

      IF (.NOT. OPEN3(LOGICAL_NAME, FSREAD3, PNAME)) THEN
         MSG = "Could not open " // LOGICAL_NAME // " (read-only)"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
      END IF

      IF (.NOT. DESC3(LOGICAL_NAME)) THEN
         MSG = "Could not get description of " // LOGICAL_NAME
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
      END IF

      CAT = FILE_CAT(LOGICAL_NAME)

      IF (((CAT .EQ. 1) .AND. (FTYPE3D .NE. GRDDED3)) .OR.
     &    ((CAT .EQ. 2) .AND. (FTYPE3D .NE. GRDDED3)) .OR.
     &    ((CAT .EQ. 3) .AND. (FTYPE3D .NE. BNDARY3))) THEN
         MSG = "Mismatch between file type and category"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
      END IF

      IF ((CAT .EQ. 2) .AND. (VGTYP3D .NE. -1)) THEN
         MSG = "Expecting VGTYP -1 in " // LOGICAL_NAME
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
      END IF

      IF ((CAT .EQ. 2) .AND. (VGTOP3D .NE. 0.)) THEN
         MSG = "Expecting VGTOP 0. in " // LOGICAL_NAME
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT1)
      END IF

      IF (FILE_CAT_FIRST(CAT)) THEN

C     We save the values that must be consistent across files of the
C     same category

         NCOLS(CAT) = NCOLS3D
         NROWS(CAT) = NROWS3D
         NTHIK(CAT) = NTHIK3D
         GDTYP(CAT) = GDTYP3D
         VGTYP(CAT) = VGTYP3D
         FTYPE(CAT) = FTYPE3D
         NLAYS(CAT) = NLAYS3D
         P_ALP(CAT) = P_ALP3D
         P_BET(CAT) = P_BET3D
         P_GAM(CAT) = P_GAM3D
         XCENT(CAT) = XCENT3D
         YCENT(CAT) = YCENT3D
         XORIG(CAT) = XORIG3D
         YORIG(CAT) = YORIG3D
         XCELL(CAT) = XCELL3D
         YCELL(CAT) = YCELL3D
         VGTOP(CAT) = VGTOP3D

         DO I = 1, NLAYS3D+1
            VGLVS(CAT, I) = VGLVS3D(I)
         END DO

         FILE_CAT_FIRST(CAT) = .FALSE.

      ELSE

C     We check that the values are consistent with other files of the
C     same category

         IF ((NCOLS3D .NE. NCOLS(CAT)) .OR.
     &       (NROWS3D .NE. NROWS(CAT)) .OR.
     &       (NTHIK3D .NE. NTHIK(CAT)) .OR.
     &       (GDTYP3D .NE. GDTYP(CAT)) .OR.
     &       (VGTYP3D .NE. VGTYP(CAT)) .OR.
     &       (FTYPE3D .NE. FTYPE(CAT)) .OR.
     &       (NLAYS3D .NE. NLAYS(CAT)) .OR.
     &       (P_ALP3D .NE. P_ALP(CAT)) .OR.
     &       (P_BET3D .NE. P_BET(CAT)) .OR.
     &       (P_GAM3D .NE. P_GAM(CAT)) .OR.
     &       (XCENT3D .NE. XCENT(CAT)) .OR.
     &       (YCENT3D .NE. YCENT(CAT)) .OR.
     &       (XORIG3D .NE. XORIG(CAT)) .OR.
     &       (YORIG3D .NE. YORIG(CAT)) .OR.
     &       (XCELL3D .NE. XCELL(CAT)) .OR.
     &       (YCELL3D .NE. YCELL(CAT)) .OR.
     &       (VGTOP3D .NE. VGTOP(CAT))) THEN
            MSG = "Inconsistent file headers in same category"
            CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
         END IF

         DO I = 1, NLAYS3D+1
            IF (VGLVS3D(I) .NE. VGLVS(CAT, I)) THEN
               MSG = "Inconsistent vertical layers in same category"
               CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
            END IF
         END DO

      END IF

C     Some parameters are extracted from the input adjoint file only

      IF (LOGICAL_NAME .EQ. "INFILE_ADJ") THEN
         SDATE = SDATE3D
         STIME = STIME3D
         TSTEP = TSTEP3D
      END IF

C     Some parameter values are not supported

      IF (NTHIK3D .NE. 1) THEN
         MSG = "NTHIK non-equal to 1 not supported"
         CALL M3EXIT(PNAME, JDATE_NONE, JTIME_NONE, MSG, XSTAT2)
      END IF

      END SUBROUTINE CHECK_FILE
