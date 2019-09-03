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

      SUBROUTINE GIT_VERBOSE()

      IMPLICIT NONE

      INCLUDE SUBST_IODECL

      LOGICAL, SAVE :: FIRSTIME = .TRUE.
      INTEGER :: LOGDEV

      IF (FIRSTIME) THEN
         LOGDEV = INIT3()
         FIRSTIME = .FALSE.
      END IF

      WRITE(LOGDEV, '(5X,A)') ""
      WRITE(LOGDEV, '(5X,A)') "*******************************"
      WRITE(LOGDEV, '(5X,A)') "***** GIT VERBOSE (START) *****"
      WRITE(LOGDEV, '(5X,A)') "*******************************"
      WRITE(LOGDEV, '(5X,A)') ""
      WRITE(LOGDEV, '(5X,A)') "-----------"
      WRITE(LOGDEV, '(5X,A)') "Last commit"
      WRITE(LOGDEV, '(5X,A)') "-----------"
      WRITE(LOGDEV, '(5X,A)') ""
      WRITE(LOGDEV, '(5X,A)') ""
      WRITE(LOGDEV, '(5X,A)') "-------------------------------------"
      WRITE(LOGDEV, '(5X,A)') "Difference with last commit (summary)"
      WRITE(LOGDEV, '(5X,A)') "-------------------------------------"
      WRITE(LOGDEV, '(5X,A)') ""
      WRITE(LOGDEV, '(5X,A)') ""
      WRITE(LOGDEV, '(5X,A)') "--------------------------------------"
      WRITE(LOGDEV, '(5X,A)') "Difference with last commit (detailed)"
      WRITE(LOGDEV, '(5X,A)') "--------------------------------------"
      WRITE(LOGDEV, '(5X,A)') ""
      WRITE(LOGDEV, '(5X,A)') ""
      WRITE(LOGDEV, '(5X,A)') "------"
      WRITE(LOGDEV, '(5X,A)') "Branch"
      WRITE(LOGDEV, '(5X,A)') "------"
      WRITE(LOGDEV, '(5X,A)') ""
      WRITE(LOGDEV, '(5X,A)') ""
      WRITE(LOGDEV, '(5X,A)') "*******************************"
      WRITE(LOGDEV, '(5X,A)') "***** GIT VERBOSE ( END ) *****"
      WRITE(LOGDEV, '(5X,A)') "*******************************"
      WRITE(LOGDEV, '(5X,A)') ""

      END SUBROUTINE GIT_VERBOSE

