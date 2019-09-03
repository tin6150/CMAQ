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

      SUBROUTINE RD_L4CHK(CGRID, JDATE, JTIME)

C     AUTHOR: Lucas A. J. Bastien
C     (based on existing CMAQ and/or CMAQ-ADJ code)
C
C     PURPOSE: Read checkpointed values from L4CHK file

C     Modules

      USE GRID_CONF

      IMPLICIT NONE

C     Include Files

      INCLUDE SUBST_IOPARMS     ! I/O parameters definitions
      INCLUDE SUBST_IOFDESC     ! File header data structure
      INCLUDE SUBST_FILES_ID    ! File definitions
      INCLUDE SUBST_IODECL      ! I/O definitions and declarations

C     Dummy arguments

      REAL, INTENT(INOUT) :: CGRID(:,:,:)
      INTEGER, INTENT(IN) :: JDATE ! current model date, coded YYYYDDD
      INTEGER, INTENT(IN) :: JTIME ! current model time, coded HHMMSS

C     External functions

      LOGICAL, EXTERNAL :: PREAD3

C     Local variables

      CHARACTER(LEN=16) :: PNAME = "RD_L4CHK"
      LOGICAL, SAVE :: FIRSTIME = .TRUE.
      INTEGER, SAVE :: LOGDEV
      CHARACTER(LEN=96) :: MSG
      INTEGER, SAVE :: STRTCOL, ENDCOL, STRTROW, ENDROW ! For INTERPX
      INTEGER :: GXOFF, GYOFF                           ! For SUBHFILE

C     ------------------------------------------------------------------

      IF ( FIRSTIME ) THEN
         FIRSTIME = .FALSE.
         LOGDEV = INIT3()

         IF (.NOT. OPEN3(CONC_L4CHK, FSREAD3, PNAME)) THEN
            MSG = "Could not open " // CONC_L4CHK // " file for reading"
            CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         IF (.NOT. DESC3(CONC_L4CHK)) THEN
            MSG = "Could not get " // CONC_L4CHK // " file description"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         IF ((NVARS3D .NE. 1) .OR. (TRIM(VNAME3D(1)) .NE. "RHOJ")) THEN
            MSG = PNAME // " assumes RHOJ is only variable in L4CHK"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         CALL SUBHFILE(CONC_L4CHK, GXOFF, GYOFF,
     &        STRTCOL, ENDCOL, STRTROW, ENDROW)

      END IF ! FIRSTIME

      IF (.NOT. INTERPX(CONC_L4CHK, "RHOJ", PNAME,
     &     STRTCOL, ENDCOL, STRTROW, ENDROW, 1, NLAYS,
     &     JDATE, JTIME, CGRID(:,:,:))) THEN

         MSG = "Could not INTERPX data from " // TRIM(CONC_L4CHK) //
     &        "; will try (P)READ3 instead"
         CALL M3WARN(PNAME, JDATE, JTIME, MSG)

C     Then maybe we are trying to read the last time step of the file,
C     for which INTERPX fails. Use (P)READ3 instead

         IF (.NOT. SUBST_READ3(CONC_L4CHK, "RHOJ", ALLAYS3,
     &        JDATE, JTIME, CGRID(:,:,:))) THEN
            MSG = "Could not read data from " // CONC_L4CHK
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

      END IF

      END SUBROUTINE RD_L4CHK
