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

      SUBROUTINE CHEM_ADJ( LGRID, JDATE, JTIME, TSTEP )

C**********************************************************************
C
C     FUNCTION: Does nothing. It is used to compile with no chemistry.
C
C**********************************************************************

      IMPLICIT NONE
      
C     Include files
 
      INCLUDE SUBST_IODECL ! I/O definitions and declarations

C     Dummy variables

      REAL, POINTER :: LGRID( :,:,:,: )
      INTEGER JDATE
      INTEGER JTIME
      INTEGER TSTEP( 2 )

C     Local variables

      LOGICAL, SAVE :: FIRSTIME
      INTEGER, SAVE :: LOGDEV

C     Main body starts here

      IF ( FIRSTIME ) THEN

         FIRSTIME = .FALSE.
         LOGDEV = INIT3()
         WRITE( LOGDEV,* ) '    '
         WRITE( LOGDEV,* ) '    Using no-op gas chem, adjoint process'
         WRITE( LOGDEV,* ) '    '
      
      END IF

      RETURN

      END SUBROUTINE CHEM_ADJ
