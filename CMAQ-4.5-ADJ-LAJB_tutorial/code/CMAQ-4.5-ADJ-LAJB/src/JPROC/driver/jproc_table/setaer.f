
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/JPROC/src/driver/jproc_table/setaer.f,v 1.1.1.1 2005/09/09 19:22:14 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)setaer.F	1.1 /project/mod3/JPROC/src/driver/jproc_table/SCCS/s.setaer.F 23 May 1997 12:44:27

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      SUBROUTINE SETAER ( NWL, MIDWL, AAER, OMAER, GAER, HAER )

C*********************************************************************
C
C  Specify aerosols
C
C    AAER(IWL) = aerosol total vertical optical depth variation with
C                wavelength.  Estimated from Elterman (1968)
C    AER(I)    = attenuation (per km) profile from Elterman (1968).
C                Given in data statement in beginning of code,
C                for 340 nm (IWL=60)
C                Same vertical shape at all wavelengths.
C                Normalized later (in subroutine SUBGRID) to total
C                vertical dep this wavelength.
C    OMAER     = aerosol single scattering albedo.  Use 0.99 for now.
C    GAER      = aerosol asymetry factor.  Use 0.61 (Hansen and
C                Travis 1974) (these are assuming particles of
C                about 0.1 micron radius index of refraction of
C                about 1.65 + 0.002i.
C    HAER      = the aerosol scale height at top of atmosphere
C                use equal to air (8.05 km)
C
C*********************************************************************

      IMPLICIT NONE

      INCLUDE 'JVALPARMS.EXT'    ! jproc parameters

C...........ARGUMENTS and their descriptions

      INTEGER      NWL                ! number of wavelength bands

      REAL         MIDWL ( MXWL )     ! wavelength band midpoints
      REAL         AAER  ( MXWL )     ! aerosol total vert opt depth
      REAL         OMAER              ! aerosol single scat albedo
      REAL         GAER               ! aerosol asymetry factor
      REAL         HAER               ! aerosol scale ht at atm top

C...........LOCAL VARIABLES and their descriptions:

      INTEGER      IWL                ! wavelength index

C*********************************************************************
C     begin body of subroutine SETAER

      DO IWL = 1, NWL
        AAER( IWL ) = 0.379 * ( 340.0 / MIDWL( IWL ) )
      END DO

      OMAER = 0.990
      GAER  = 0.610
      HAER  = 8.05

      RETURN
      END