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
C     AUTHOR: Lucas A. J. Bastien

      SUBROUTINE ADJVERBOSE()

C     PURPOSE:
C     Writes some verbose into the log file.

C     Module(s)

      USE ADJPRM

      IMPLICIT NONE

C     Include file(s)

      INCLUDE SUBST_IODECL  ! I/O definitions and declarations

C     Local variable(s)

      LOGICAL, SAVE :: FIRSTIME = .TRUE. ! Is it the first time running
                                         ! this subroutine?
      INTEGER, SAVE :: LOGDEV            ! Logical unit of log file

C     ------------------------------------------------------------------

      IF ( FIRSTIME ) THEN
         FIRSTIME = .FALSE.
         LOGDEV = INIT3 ()
      END IF

      WRITE (LOGDEV, '(/, 5X, A)') "----- ADJVERBOSE (BEGIN) -----"
      WRITE (LOGDEV, '(5X, A, 1X, L1)') "RTO_FWD"       , RTO_FWD
      WRITE (LOGDEV, '(5X, A, 1X, L1)') "RTO_FWD_RST"   , RTO_FWD_RST
      WRITE (LOGDEV, '(5X, A, 1X, L1)') "RTO_BWD"       , RTO_BWD
      WRITE (LOGDEV, '(5X, A, 1X, L1)') "RTO_BWD_RST"   , RTO_BWD_RST
      WRITE (LOGDEV, '(5X, A, 1X, L1)') "RTO_CHK"       , RTO_CHK
      WRITE (LOGDEV, '(5X, A, 1X, I8)') "ADJ_RUNLEN"    , ADJ_RUNLEN
      WRITE (LOGDEV, '(5X, A, 1X, I8)') "ADJ_TOTLEN"    , ADJ_TOTLEN
      WRITE (LOGDEV, '(5X, A, 1X, I8)') "ADJ_STDATE_TOT", ADJ_STDATE_TOT
      WRITE (LOGDEV, '(5X, A, 1X, I8)') "ADJ_STTIME_TOT", ADJ_STTIME_TOT
      WRITE (LOGDEV, '(5X, A, 1X, I8)') "ADJ_TOTLEN"    , ADJ_TOTLEN
      WRITE (LOGDEV, '(5X, A, 1X, A )') "REC_SPECIES"   , REC_SPECIES
      WRITE (LOGDEV, '(5X, A, 1X, A )') "REC_VAR"       , REC_VAR
      WRITE (LOGDEV, '(5X, A, 1X, A )') "FIL_ASTEP"     , FIL_ASTEP
      WRITE (LOGDEV, '(5X, A, 1X, I8)') "TSTEP_ACONC"   , TSTEP_ACONC
      WRITE (LOGDEV, '(5X, A, 1X, I8)') "TSTEP_AL5CHK"  , TSTEP_AL5CHK
      WRITE (LOGDEV, '(5X, A, 1X, L1)') "XFIRST_FWD"    , XFIRST_FWD
      WRITE (LOGDEV, '(5X, A, 1X, L1)') "XFIRST_BWD"    , XFIRST_BWD
      WRITE (LOGDEV, '(5X, A, 1X, L1)') "L5FCHK_READ"   , L5FCHK_READ
      WRITE (LOGDEV, '(5X, A, 1X, L1)') "L5FCHK_WRITE"  , L5FCHK_WRITE
      WRITE (LOGDEV, '(5X, A, 1X, I8)') "L5FCHK_DATE"   , L5FCHK_DATE
      WRITE (LOGDEV, '(5X, A, 1X, I8)') "L5FCHK_TIME"   , L5FCHK_TIME
      WRITE (LOGDEV, '(5X, A, /)') "----- ADJVERBOSE (END)   -----"
      RETURN

      END SUBROUTINE ADJVERBOSE
