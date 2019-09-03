
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/ICON/src/par/par_noop/reconfig_domain_noop.F,v 1.1.1.1 2005/09/09 19:23:43 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C ----------------------------------------------------------------------------
C Purpose:
C
C   A noop counter part of reconfig_domain.F
C
C Note: Description of variables (see reconfig_domain.F)
C
C Revision history:
C
C   Orginal version: 02/15/00 by David Wong
C                    06/21/02 David Wong, LM
C                      -- fixed a bug: recompute ROWSX_PE and COLSX_PE
C ----------------------------------------------------------------------------

      SUBROUTINE RECONFIG_DOMAIN ( CALLER, GL_NROWS, GL_NCOLS, NLAYS, NSPCS,
     &                             NTHIK, NROWS, NCOLS, NPROW, NPCOL,
     &                             MNDIS, MEDIS, MSDIS, MWDIS,
     &                             ROWSX_PE, COLSX_PE, MY_NROWS, MY_NCOLS,
     &                             MY_NBNDY, IERROR )

      IMPLICIT NONE

      CHARACTER( * ), INTENT( IN ) :: CALLER
      INTEGER :: GL_NROWS
      INTEGER :: GL_NCOLS
      INTEGER :: NLAYS
      INTEGER :: NSPCS
      INTEGER :: NTHIK
      INTEGER :: NROWS
      INTEGER :: NCOLS
      INTEGER :: NPROW
      INTEGER :: NPCOL
      INTEGER :: MNDIS
      INTEGER :: MEDIS
      INTEGER :: MSDIS
      INTEGER :: MWDIS
      INTEGER :: ROWSX_PE(2,NPROW*NPCOL)
      INTEGER :: COLSX_PE(2,NPROW*NPCOL)
      INTEGER :: MY_NROWS
      INTEGER :: MY_NCOLS
      INTEGER :: MY_NBNDY
      INTEGER :: IERROR

      ROWSX_PE(1,1) = 1
      ROWSX_PE(2,1) = GL_NROWS
      COLSX_PE(1,1) = 1
      COLSX_PE(2,1) = GL_NCOLS

      MY_NROWS = GL_NROWS
      MY_NCOLS = GL_NCOLS
      MY_NBNDY = 2*NTHIK * ( MY_NROWS + MY_NCOLS + 2*NTHIK )

      RETURN
      END SUBROUTINE RECONFIG_DOMAIN
