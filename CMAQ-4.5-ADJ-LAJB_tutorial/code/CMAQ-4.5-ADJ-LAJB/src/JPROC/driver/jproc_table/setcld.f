
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


C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/JPROC/src/driver/jproc_table/setcld.f,v 1.1.1.1 2005/09/09 19:22:14 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)setcld.F	1.1 /project/mod3/JPROC/src/driver/jproc_table/SCCS/s.setcld.F 23 May 1997 12:44:29

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      SUBROUTINE SETCLD ( NLAYS, NLEVS, NSUBKM, IBASE, ITOP, CLOUD,
     &                    OMCLD, GCLD )

C*********************************************************************
C
C   CLOUD MUST BE SPECIFIED EVEN FOR CLEAR PHOTOLYSIS RATES
C   A FINE GRID IS REQUIRED BY THE DELTA-EDDINGTON SOLVER
C   DEPTH = cloud optical depth
C   IBASE = cloud base index (height/km  +  1)
C   ITOP =  cloud top index (height/km  +  1)
C           NSUBKM = cloud sublayers/km
C           NSBTOT = total number of cloud sublayers (36 or less)
C           NLAYS = total number of atmospheric layers
C   CLOUD(K) = cloud optical depth profile.  Relative optical depth
C           cloud sublayer.  Assume constant cloud profile for now
C           Re- normalize to total optical depth
C           OMCLD = single scattering cross sect.  Use 0.9995
C           GCLD = asymetry factor.  Use 0.875
C
C*********************************************************************

      IMPLICIT NONE

      INCLUDE 'JVALPARMS.EXT'    ! jproc parameters

C...........ARGUMENTS and their descriptions

      INTEGER      NLAYS              ! total # of atm layers
      INTEGER      NLEVS              ! number of levels
      INTEGER      NSUBKM             ! cloud sublayers/km
      INTEGER      IBASE              ! cloud base index
      INTEGER      ITOP               ! cloud top index

      REAL         CLOUD( 48 )        ! cloud optical depth profile
      REAL         OMCLD              ! cloud single scat cross sect
      REAL         GCLD               ! cloud asymetry factor

C...........LOCAL VARIABLES and their descriptions:

      INTEGER      K                  ! cloud sublayer index
      INTEGER      NSBTOT             ! total # of cloud sublayers 

      REAL         CTOT               ! total cloud column
      REAL         DEPTH              ! optical cloud depth

C*********************************************************************
C     begin body of subroutine SETCLD

      DEPTH = 0.0

      IBASE = 20
      ITOP  = 30

      NSUBKM = 36 / ( ITOP - IBASE )
      NSBTOT = NSUBKM * ( ITOP - IBASE )
      NLAYS  = MXLEV + ( NSUBKM - 1 ) * ( ITOP - IBASE )
      NLEVS  = NLAYS + 1

      DO K = 1, NSBTOT
        CLOUD( K ) = 1.0
      END DO

C...normalize cloud profile

      CTOT = 0

      DO K = 1, NSBTOT
        CTOT = CTOT + CLOUD( K )
      END DO

      DO K = 1, NSBTOT
        CLOUD( K ) = DEPTH / CTOT
      END DO

      OMCLD = 1.000
      GCLD  = 0.860

      RETURN
      END
