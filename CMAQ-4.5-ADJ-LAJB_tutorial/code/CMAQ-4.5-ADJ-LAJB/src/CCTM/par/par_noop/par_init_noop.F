
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
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/CCTM/src/par/par_noop/par_init_noop.F,v 1.1.1.1 2005/09/09 18:56:06 sjr Exp $

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%

!     SUBROUTINE PAR_INIT( CALLER, GL_NROWS, GL_NCOLS, NLAYS, NSPCS,
!    &                     NTHIK, NROWS, NCOLS, NPROW, NPCOL,
!    &                     MNDIS, MEDIS, MSDIS, MWDIS,
!    &                     ROWSX_PE, COLSX_PE, MY_NROWS, MY_NCOLS,
!    &                     MY_NBNDY, CLOCK, IERROR )
      SUBROUTINE PAR_INIT( CALLER, NSPCS, CLOCK, IERROR )
C.....................................................................
C
C  PURPOSE:    No-operation version of parallel initialization, for
C              running in serial configuration. Local processor
C              dimensions are set to the one-processor values.
C              
C
C  REVISION HISTORY: 
C       Original version 10/1998 by Al Bourgeois for merging parallel
C                and serial codes.
C       Modified 01/1998 by Al Bourgeois to fix subscripts in arrays 
C                ROWSX_PE and COLSX_PE. 
C       Modified 11/2001 by Jeff Young for dynamic alloc version
C       Modified 31/01/05 J.Young: dyn alloc - establish both horizontal &
C                vertical domain specifications in one module
C
C
C  ARGUMENT LIST DESCRIPTION:
C  IN:
C     CHARACTER*16 CALLER       ! Calling program name.
C     INTEGER GL_NROWS          ! Number of rows in entire grid.
C     INTEGER GL_NCOLS          ! Number of columns in entire grid.
C     INTEGER NLAYS             ! Number of layers in entire grid.
C     INTEGER NSPCS             ! Number of species in CGRID.
C     INTEGER NTHIK             ! Boundary thickness (cells).
C     INTEGER NROWS             ! Row dimension of local-processor arrays.
C     INTEGER NCOLS             ! Column dimension of local-processor arrays.
C     INTEGER NPROW             ! Number of processors across grid rows.
C     INTEGER NPCOL             ! Number of processors across grid columns.
C     INTEGER MNDIS      ! Maximum stencil displacement in the north direction.
C     INTEGER MEDIS      ! Maximum stencil displacement in the east direction.
C     INTEGER MSDIS      ! Maximum stencil displacement in the south direction.
C     INTEGER MWDIS      ! Maximum stencil displacement in the west direction.
C
C  OUT:
C     INTEGER ROWSX_PE(2,0:NPROW*NPCOL-1)  ! Row range for each PE.
C                               ! ROWSX_PE(1,*) is the starting row index.
C                               ! ROWSX_PE(2,*) is the ending row index.
C
C     INTEGER COLSX_PE(2,0:NPROW*NPCOL-1)  ! Column range for each PE.
C                               ! COLSX_PE(1,*) is the starting column index.
C                               ! COLSX_PE(2,*) is the ending column index.
C
C     INTEGER MY_NROWS          ! Local number of grid rows actually used.
C     INTEGER MY_NCOLS          ! Local number of grid columns actually used.
C     INTEGER MY_NBNDY          ! Local number of boundary cells actually used.
C     REAL    CLOCK             ! Wall-clock time (sec) at MPI initialization.
C     INTEGER IERROR            ! Error code.
C
C
C  LOCAL VARIABLE DESCRIPTION:  see below
C
C  CALLS:  None 
C
C........................................................................

      USE GRID_CONF             ! horizontal & vertical domain specifications

      IMPLICIT  NONE

C....... Arguments:

C Calling program name (not used)
      CHARACTER( * ), INTENT( IN ) :: CALLER

      INTEGER NSPCS             ! Number of species in CGRID.
      REAL    CLOCK             ! Wall-clock time (sec) at MPI initialization.
      INTEGER IERROR            ! Error code.

C....... Local Variables:

      INTEGER NPROCS
      CHARACTER( 96 ) :: MSG

C.......   Set error code to zero.
      IERROR = 0

      NPROCS = 1
      MYPE = 0

C Set up horizontal domain and calculate processor-to-subdomain maps
C and define vertical layer structure (in module GRID_CONF)

      IF ( .NOT. GRID_INIT ( NPROCS, MYPE ) ) THEN
         MSG = '*** Failure defining domain configuration'
         CALL M3WARN ( 'PAR_INIT', 0, 0, MSG )
         IERROR = 1
         RETURN
         END IF

      RETURN
      END
