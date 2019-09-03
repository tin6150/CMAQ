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

      SUBROUTINE RD_L2CHK(CGRID, JDATE, JTIME)

C     AUTHOR: Lucas A. J. Bastien
C
C     PURPOSE: Read checkpointed values from L2CHK file

C     Modules

      USE GRID_CONF

      IMPLICIT NONE

C     Include Files

      INCLUDE SUBST_IOPARMS     ! I/O parameters definitions
      INCLUDE SUBST_IOFDESC     ! File header data structure
      INCLUDE SUBST_FILES_ID    ! File definitions
      INCLUDE SUBST_IODECL      ! I/O definitions and declarations

C     Dummy arguments

      REAL, INTENT(INOUT) :: CGRID(:,:,:,:)
      INTEGER, INTENT(IN) :: JDATE ! current model date, coded YYYYDDD
      INTEGER, INTENT(IN) :: JTIME ! current model time, coded HHMMSS

C     Local variables

      CHARACTER(LEN=16) :: PNAME = "RD_L2CHK"
      LOGICAL, SAVE :: FIRSTIME = .TRUE.
      INTEGER, SAVE :: LOGDEV
      CHARACTER(LEN=96) :: MSG
      INTEGER, SAVE :: STRTCOL, ENDCOL, STRTROW, ENDROW ! For INTERPX
      INTEGER :: GXOFF, GYOFF                           ! For SUBHFILE
      INTEGER, SAVE :: NVARS
      CHARACTER(LEN=16), SAVE :: VNAME(MXVARS3)
      INTEGER :: V

C     ------------------------------------------------------------------

      IF ( FIRSTIME ) THEN
         FIRSTIME = .FALSE.
         LOGDEV = INIT3()

         IF (.NOT. OPEN3(CONC_L2CHK, FSREAD3, PNAME)) THEN
            MSG = "Could not open " // CONC_L2CHK // " file for reading"
            CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         IF (.NOT. DESC3(CONC_L2CHK)) THEN
            MSG = "Could not get " // CONC_L2CHK // " file description"
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

         CALL SUBHFILE(CONC_L2CHK, GXOFF, GYOFF,
     &        STRTCOL, ENDCOL, STRTROW, ENDROW)

         NVARS = NVARS3D
         DO V=1,NVARS
            VNAME(V) = VNAME3D(V)
         END DO

      END IF ! FIRSTIME

      DO V=1,NVARS

         IF (.NOT. INTERPX(CONC_L2CHK, VNAME(V), PNAME,
     &        STRTCOL, ENDCOL, STRTROW, ENDROW, 1, NLAYS,
     &        JDATE, JTIME, CGRID(:,:,:,V))) THEN
            MSG = "Could not read data from " // CONC_L2CHK
            CALL M3EXIT(PNAME, JDATE, JTIME, MSG, XSTAT1)
         END IF

      END DO

      END SUBROUTINE RD_L2CHK
