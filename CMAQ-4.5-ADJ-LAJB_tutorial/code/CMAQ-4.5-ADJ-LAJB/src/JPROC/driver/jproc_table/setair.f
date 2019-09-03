
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/JPROC/src/driver/jproc_table/setair.f,v 1.1.1.1 2005/09/09 19:22:14 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)setair.F	1.1 /project/mod3/JPROC/src/driver/jproc_table/SCCS/s.setair.F 23 May 1997 12:44:28

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      SUBROUTINE SETAIR ( NWL, MIDWL, HAIR, OMRAY, GRAY, ARAYL )

C*********************************************************************
C
C  Specify air/Rayleigh parameters
C    HAIR      = air scale height, used to estimate ozone density
C                   column a upper boundary (50km).
C    OMRAY     = single scattering albedo, Rayleigh.  Use 1.00
C    GRAY      =  asymetry factor for Rayleigh scattering.  Use 0.0
C    ARAYL(KL) = Rayleigh scattering cross section, from
C                Frohlich and Shaw, Appl.Opt. v.11, p.1773 (1980).
C                overrides tabulation of JDATA.BASE
C
C*********************************************************************

      IMPLICIT NONE

      INCLUDE 'JVALPARMS.EXT'    ! jproc parameters

C...........ARGUMENTS and their descriptions

      INTEGER      NWL                ! number of wavelength bands

      REAL         HAIR               ! air scale height
      REAL         OMRAY              ! single scat albedo, Rayleigh
      REAL         GRAY               ! asymetry fact for Rayleigh scat
      REAL         ARAYL ( MXWL )     ! Rayleigh scat cross section
      REAL         MIDWL ( MXWL )     ! wavelength band midpoints

C...........LOCAL VARIABLES and their descriptions:

      INTEGER      IWL                ! wavelength index

      REAL         XX                 ! intermediate var
      REAL         WMICRON            ! wavelength in microns

C*********************************************************************
C     begin body of subroutine SETAIR

      HAIR  = 8.05
      OMRAY = 1.0
      GRAY  = 0.0

      DO IWL = 1, NWL
        WMICRON = MIDWL( IWL ) / 1.0E3
        XX = 3.916 + 0.074 * WMICRON + 0.050 / WMICRON
        ARAYL( IWL ) = 3.90E-28 / WMICRON**XX
      END DO

      RETURN
      END
