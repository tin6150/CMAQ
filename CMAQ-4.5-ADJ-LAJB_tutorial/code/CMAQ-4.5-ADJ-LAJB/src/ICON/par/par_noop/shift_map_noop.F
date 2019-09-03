
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/ICON/src/par/par_noop/shift_map_noop.F,v 1.1.1.1 2005/09/09 19:23:43 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

C ----------------------------------------------------------------------------
C Purpose:
C
C   A noop counter part of shift_map.F
C
C Note: Description of variables (see shift_map.F)
C
C Revision history:
C
C   Orginal version: 02/15/00 by David Wong
C
C ----------------------------------------------------------------------------

        SUBROUTINE SHIFT_MAP (CONC, COL_LOC, ROW_LOC, NCOLS, NROWS, MY_NCOLS,
     &                        MY_NROWS, GL_NCOLS_IN, GL_NROWS_IN, NCOLS_IN,
     &                        NROWS_IN, NLAYS_IN, NSPCS_IN)

        IMPLICIT NONE

        INTEGER, INTENT(IN)    :: NROWS, NCOLS, MY_NROWS, MY_NCOLS
        INTEGER, INTENT(IN)    :: GL_NROWS_IN, GL_NCOLS_IN
        INTEGER, INTENT(IN)    :: NROWS_IN, NCOLS_IN, NLAYS_IN, NSPCS_IN
        REAL, INTENT(INOUT)    :: CONC(NCOLS_IN, NROWS_IN, NLAYS_IN, NSPCS_IN)
        INTEGER, INTENT(INOUT) :: ROW_LOC(NCOLS, NROWS), COL_LOC(NCOLS, NROWS)

        RETURN
        END SUBROUTINE SHIFT_MAP
