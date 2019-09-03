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

      SUBROUTINE WALLTIME(TIME)
C
C     AUTHOR: Lucas A. J. Bastien
C
C     PURPOSE (SUMMARY): Get walltime. The walltime is relative to an
C     arbitrary reference so the usefull quantities are the differences
C     between the outputs of different calls to this routine.
C
C     NOTES: there are two versions of this routine: a serial version
C     and a parallel version.

      IMPLICIT NONE

C     Include files

C     Dummy argument

      DOUBLEPRECISION, INTENT(OUT) :: TIME ! walltime

C     Local variables

      REAL :: RTIME

      CALL CPU_TIME(RTIME)
      TIME = DBLE(RTIME)

      END SUBROUTINE WALLTIME
