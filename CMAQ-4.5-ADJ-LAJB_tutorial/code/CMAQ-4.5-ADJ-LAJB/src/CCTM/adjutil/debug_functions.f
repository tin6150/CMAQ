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

      FUNCTION DBG_MINMAX_STR_2D(A, D1, D2) RESULT(OUT)

      IMPLICIT NONE

C     Dummy variables

      REAL, INTENT(IN) :: A(D1,D2)
      INTEGER, INTENT(IN) :: D1, D2
      CHARACTER(LEN=30) :: OUT

C     Local variables

      INTEGER :: I1, I2
      REAL :: MINI, MAXI

      MINI = A(1,1)
      MAXI = MINI
      DO I1=1,D1
         DO I2=1,D2
            MINI = MIN(MINI, A(I1, I2))
            MAXI = MAX(MAXI, A(I1, I2))
         END DO
      END DO

      WRITE (OUT, '(A4,E10.5,A6,E10.5)') "MIN=", MINI, ", MAX=", MAXI

      END FUNCTION DBG_MINMAX_STR_2D

      FUNCTION DBG_MINMAX_STR_4D(A, D1, D2, D3, D4) RESULT(OUT)

      IMPLICIT NONE

C     Dummy variables

      REAL, INTENT(IN) :: A(D1,D2,D3,D4)
      INTEGER, INTENT(IN) :: D1, D2, D3, D4
      CHARACTER(LEN=30) :: OUT

C     Local variables

      INTEGER :: I1, I2, I3, I4
      REAL :: MINI, MAXI

      MINI = A(1,1,1,1)
      MAXI = MINI
      DO I1=1,D1
         DO I2=1,D2
            DO I3=1,D3
               DO I4=1,D4
                  MINI = MIN(MINI, A(I1, I2, I3, I4))
                  MAXI = MAX(MAXI, A(I1, I2, I3, I4))
               END DO
            END DO
         END DO
      END DO

      WRITE (OUT, '(A4,E10.5,A6,E10.5)') "MIN=", MINI, ", MAX=", MAXI

      END FUNCTION DBG_MINMAX_STR_4D
