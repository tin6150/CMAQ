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

      SUBROUTINE BARRIER(JDATE, JTIME)
C
C     AUTHOR: Lucas A. J. Bastien
C
C     PURPOSE (SUMMARY): Wait for all processors to reach this point.
C
C     NOTES: There are two versions of this routine: a serial version
C     and a parallel version. This pair of subroutine was written so
C     that a barrier could be placed in a piece of code without having
C     to include the mpi header file in that piece of code. The
C     motivation was to be able to have barriers where necessary when
C     running in parallel mode (in which case compile CCTM using the
C     parallel version), while still be able to compile the code for
C     serial runs without having to link to any MPI ibrary at all (in
C     which case compile CCTM using the serial version). There might be
C     instances when the host machine does not have any implementation
C     of MPI installed; CMAQ should still be usable on these machines.
C
      IMPLICIT NONE

C     Dummy argument

      INTEGER, INTENT(IN) :: JDATE ! current model date (YYYYDDD)
      INTEGER, INTENT(IN) :: JTIME ! current model time (HHMMSS)

      RETURN

      END SUBROUTINE BARRIER
