
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/JPROC/src/driver/jproc_table/o3scal.f,v 1.1.1.1 2005/09/09 19:22:14 sjr Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C @(#)o3scal.F	1.1 /project/mod3/JPROC/src/driver/jproc_table/SCCS/s.o3scal.F 23 May 1997 12:44:20

C:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
       SUBROUTINE O3SCAL ( O3, HO3, XLAT, DOBNEW )

C*********************************************************************
C
C  adjustment of O3 profiles to a user-selected dobson value.
C   select value of DOBNEW in main program
C   if don't want to use, don't call this subroutine
C
C*********************************************************************

      IMPLICIT NONE
            
      INCLUDE 'JVALPARMS.EXT'    ! jproc parameters

C...........ARGUMENTS and their descriptions

      REAL         O3( MXLEV )        ! ozone profile
      REAL         HO3                ! ozone scale height
      REAL         XLAT               ! latitudinal band
      REAL         DOBNEW             ! new dobson unit

C...........LOCAL VARIABLES and their descriptions:
     
      INTEGER      I                  ! level index
     
      REAL         DOBSREF            ! reference dobson unit
               
C*********************************************************************
C     begin body of subroutine O3SCAL2

      DOBSREF = O3( MXLEV ) * 1.0E5 * HO3

      DO I = 1, MXLEV
        DOBSREF = DOBSREF + O3( I ) * 1.0E5
      END DO

      DOBSREF = DOBSREF / 2.687E16
      print *, 'Latitude: ', XLAT, '   oldDOBS=', DOBSREF,
     &         '   newDOBS=', DOBNEW

      DO I = 1, MXLEV
        O3( I ) = O3( I ) * DOBNEW / DOBSREF
      END DO

      RETURN
      END