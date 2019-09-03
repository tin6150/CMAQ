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

      SUBROUTINE FIND_LUN(LUN)

C     This subroutine finds the first logical unit number (LUN) that is
C     not already associated to an opened file. This logical unit number
C     can then be used to open a new file. Note that this approach is
C     faulty in that it allows for race conditions to happen. There is
C     nothing to prevent that the logical unit number doesn't get
C     associated with a file between the moment this subroutine returns
C     and the moment its output LUN is used as intended to (i.e. to open
C     a file).

      IMPLICIT NONE

      INTEGER, INTENT(OUT) :: LUN

      LOGICAL :: IS_OPENED

      LUN = -1
      IS_OPENED = .TRUE.

      DO WHILE (IS_OPENED)

         LUN = LUN + 1
         INQUIRE (UNIT=LUN, OPENED=IS_OPENED)

      END DO

      RETURN

      END SUBROUTINE FIND_LUN
