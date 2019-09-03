
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/JPROC/src/driver/jproc_table/setalb.f,v 1.1.1.1 2005/09/09 19:22:14 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)setalb.F	1.1 /project/mod3/JPROC/src/driver/jproc_table/SCCS/s.setalb.F 23 May 1997 12:44:28

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      SUBROUTINE SETALB ( NWL, MIDWL, ALBEDO )

C*********************************************************************
C
C  Set the albedo of the surface. 
C    Use best estimate albedo of Demerjian et al.,
C    Adv.Env.Sci.Tech.,v.10,p.369, (1980)
C
C*********************************************************************

      IMPLICIT NONE

      INCLUDE 'JVALPARMS.EXT'    ! jproc parameters

C...........ARGUMENTS and their descriptions

      INTEGER      NWL                ! number of wavelength bands

      REAL         MIDWL ( MXWL )     ! wavelength band midpoints
      REAL         ALBEDO( MXWL )     ! ground albedo

C...........LOCAL VARIABLES and their descriptions:

      INTEGER      IWL                ! wavelength index

C*********************************************************************
C     begin body of subroutine SETALB

      DO IWL = 1, NWL

        IF ( MIDWL( IWL ) .LT. 400.0 ) THEN
          ALBEDO( IWL ) = 0.05
        ELSE IF (( MIDWL( IWL ) .GE. 400.0 ) .AND.
     &           ( MIDWL( IWL ) .LT. 450.0 )) THEN
          ALBEDO( IWL ) = 0.06
        ELSE IF (( MIDWL( IWL ) .GE. 450.0 ) .AND.
     &           ( MIDWL( IWL ) .LT. 500.0 )) THEN
          ALBEDO( IWL ) = 0.08
        ELSE IF (( MIDWL( IWL ) .GE. 500.0 ) .AND.
     &           ( MIDWL( IWL ) .LT. 550.0 )) THEN
          ALBEDO( IWL ) = 0.10
        ELSE IF (( MIDWL( IWL ) .GE. 550.0 ) .AND.
     &           ( MIDWL( IWL ) .LT. 600.0 )) THEN
          ALBEDO( IWL ) = 0.11
        ELSE IF (( MIDWL( IWL ) .GE. 600.0 ) .AND.
     &           ( MIDWL( IWL ) .LT. 640.0 )) THEN
          ALBEDO( IWL ) = 0.12
        ELSE IF (( MIDWL( IWL ) .GE. 640.0 ) .AND.
     &           ( MIDWL( IWL ) .LT. 660.0 )) THEN
          ALBEDO( IWL ) = 0.135
        ELSE IF ( MIDWL( IWL ) .GE. 660.0 ) THEN
          ALBEDO( IWL ) = 0.15
        END IF

      END DO

      RETURN
      END
