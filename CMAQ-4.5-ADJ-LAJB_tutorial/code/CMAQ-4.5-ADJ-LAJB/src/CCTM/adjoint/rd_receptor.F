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

      SUBROUTINE RD_RECEPTOR(RECEPTOR, JDATE, JTIME)

C     AUTHOR: Lucas A. J. Bastien
C     (based on existing CMAQ and/or CMAQ-ADJ code)
C
C     PURPOSE: Read receptor

C     Modules

      USE GRID_CONF
      USE ADJPRM                ! Adjoint parameters

      IMPLICIT NONE

C     Include Files

      INCLUDE SUBST_IOPARMS     ! I/O parameters definitions
      INCLUDE SUBST_IODECL      ! I/O definitions and declarations
      INCLUDE SUBST_FILES_ID    ! Files logical names

C     Dummy arguments

      REAL, INTENT(INOUT) :: RECEPTOR(NCOLS, NROWS)
      INTEGER, INTENT(IN) :: JDATE ! current model date, coded YYYYDDD
      INTEGER, INTENT(IN) :: JTIME ! current model time, coded HHMMSS

C     Local variables

      CHARACTER(LEN=16) :: PNAME = "RD_RECEPTOR"
      LOGICAL, SAVE :: FIRSTIME = .TRUE.
      INTEGER, SAVE :: LOGDEV
      CHARACTER(LEN=96) :: MSG
      INTEGER, SAVE :: STRTCOL, ENDCOL, STRTROW, ENDROW ! For INTERPX
      INTEGER :: GXOFF, GYOFF                           ! For SUBHFILE

C     ------------------------------------------------------------------

      IF ( FIRSTIME ) THEN
         FIRSTIME = .FALSE.
         LOGDEV = INIT3()

         IF (.NOT. OPEN3(FIL_REC, FSREAD3, PNAME)) THEN
            MSG = "Could not open " // FIL_REC // " file for reading"
            CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         CALL SUBHFILE(FIL_REC, GXOFF, GYOFF,
     &        STRTCOL, ENDCOL, STRTROW, ENDROW)

      END IF ! FIRSTIME

      IF (.NOT. INTERPX(FIL_REC, REC_VAR, PNAME,
     &     STRTCOL, ENDCOL, STRTROW, ENDROW, 1, 1,
     &     JDATE, JTIME, RECEPTOR)) THEN
         MSG = "Could not read data from " // FIL_REC
         CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
      END IF

      END SUBROUTINE RD_RECEPTOR
