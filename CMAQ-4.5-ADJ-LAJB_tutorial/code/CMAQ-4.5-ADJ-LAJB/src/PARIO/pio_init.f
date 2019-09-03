C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /global/home/groups-sw/ac_seasonal/lbastien/CMAQ/v4.5-ADJ/models/PARIO/src/pio_init.f,v 1.1.1.1 2005/09/09 16:18:17 sjr Exp $

      LOGICAL FUNCTION PIO_INIT ( CALLER, GL_NROWS, GL_NCOLS, NLAYS,
     &                            NTHIK, NROWS, NCOLS, NPROW, NPCOL,
     &                            NPROCS, MYPE )
C ....................................................................

C  PURPOSE:    Initialize parallel Models-3 I/O API library routines.
C              This includes starting up the I/O API and calculating
C              processor-to-subdomain maps.

C  RETURN VALUE: The function as written always returns a value of TRUE.
C       (i.e., this could have been written as a subroutine, but is
C       written as a FUNCTION in the anticipation that failure conditions
C       will be added.) If subroutine ALLOINT a non-zero error code,
C       M3WARN is called and execution is terminated. Subroutine
C       SUBDMAP will also terminate program execution if an error is
C       detected during memory allocation.

C
C  REVISION HISTORY:
C       Original version  2/96 by Al Bourgeois for parallel implementation.
C       Modified 6/98 by AJB for PAR_IO library, added error code.
C       Modified 07/08/1998 by AJB to set IO_GRP and MY_IO_PE.
C       Modified 07/29/1998 by AJB to allow setting of NPROW, NPCOL outside.
C                Also added synchronization of return code across processors.
C       Modified 08/25/1998 to remove MPI initialization, and to pass in
C                grid decomposition variables through the argument list.
C       Modified 12/07/1998 by Al Bourgeois to add EXTERNAL declarations.
C       Modified 01/26/1999 by Al Bourgeois to allocate memory for write maps.
C       Modified 06/16/1999 by Al Bourgeois to remove interprocessor
C          synchronization. This removes the guarantee that all processors
C          return the same error code, and a "hang" state can occur if
C          PM3EXIT is not called on the condition that this function fails.
C       Modified 08/06/1999 by Al Bourgeois to simplify error handling.
C                12 Apr 2001 by J. Young to eliminate I/O processors
C       Modified 02/06/2004 by David Wong
C          -- uses f90 syntax to allocate memory to avoid using DYNMEM
C             library
C       Modified 08/26/2004 by David Wong
C          -- added a statement to check whether allocated memory is already
C             exist

C
C  ARGUMENT LIST DESCRIPTION:
C  IN:
C     CHARACTER*16 CALLER        ! Calling program name.
C     INTEGER GL_NROWS           ! Number of rows in entire grid.
C     INTEGER GL_NCOLS           ! Number of columns in entire grid.
C     INTEGER NLAYS              ! Number of layers in entire grid.
C     INTEGER NTHIK              ! Cell thickness of grid boundary.
C     INTEGER NPROW              ! Number of processors across grid rows.
C     INTEGER NPCOL              ! Number of processors across grid columns.
C     INTEGER NROWS              ! Row dimension of local-processor arrays.
C     INTEGER NCOLS              ! Column dimension of local-processor arrays.
C     INTEGER NPROCS             ! Number of processors.
C     INTEGER MYPE               ! Local processor id.

C  OUT:
C   COMMON BLOCK PIOGRID:
C     INTEGER  NPROWD            ! Number of processors across grid rows.
C     INTEGER  NPCOLD            ! Number of processors across grid columns.
C     INTEGER  GNROWS            ! Number of rows in global grid.
C     INTEGER  GNCOLS            ! Number of columns in global grid.
C     INTEGER  BTHICK            ! Cell thickness of grid boundary.
C     INTEGER  NUMROWS           ! Row dimension of local-processor arrays.
C     INTEGER  NUMCOLS           ! Column dimension of local-processor arrays.
C     INTEGER  MY_NROWS          ! Local number of grid rows.
C     INTEGER  MY_NCOLS          ! Local number of grid columns.
C     INTEGER  MAXCELLS          ! Maximum subdomain size over PEs.
C     INTEGER  NGB_PE(8)         ! PE neighborhood, first north then clockwise.

C   COMMON BLOCK PIOVARS:
C     INTEGER  MY_PE             ! Local processor id.
C     INTEGER  IO_PE             ! Id of processor used for file I/O.

C   COMMON BLOCK PIOMAPS:
C     INTEGER  NUMPROCS             ! Number of processors.
C     INTEGER  NROWS_PE(NUMPROCS)   ! Number rows in each processor.
C     INTEGER  NCOLS_PE(NUMPROCS)   ! Number columns in each processor.
C     INTEGER  ROWSX_PE(2,NUMPROCS) ! Row range for each PE.
C     INTEGER  COLSX_PE(2,NUMPROCS) ! Column range for each PE.

C  LOCAL VARIABLE DESCRIPTION:  see below

C  CALLS:  INITM3IO, SUBDMAP, WRSUBDMAP, ALLOINT, SETINT, M3WARN

C  NOTES: Uses dynamic memory allocation for processor-to-subdomain
C    maps NROWS_PE, ROWSX_PE, NCOLS_PE, and COLSX_PE.

C    To hide parallelism, domain decomposition information is maintained
C    via COMMON blocks instead of subroutine arguments.

C    The group-I/O flag, IO_GRP, determines if a processor will partici-
C    pate in file reading operations. This depends on the arrangement
C    of processors distributed across grid rows (NPROW). The following
C    diagram shows the situation for an example subdomain layout. In the
C    example, IO_GRP would be set to 1 on PE 0 and PE 4, and set to 0 on
C    all other PEs.

C                                                    NPCOL
C  Example subdomain layout         _____________________________________
C  for 8 processors with           |         |         |        |        |
C  NPROW=2, NPCOL=4.               | I/O     |         |        |        |
C                                  |    4    |    5    |    6   |    7   |
C  PE 0 will read                  |         |         |        |        |
C  for PEs 0,1,2,3          NPROW  |_________|_________|________|________|
C                                  |         |         |        |        |
C  PE 4 will read                  | I/O     |         |        |        |
C  for PEs 4,5,6,7                 |    0    |    1    |    2   |    3   |
C                                  |         |         |        |        |
C                                  |         |         |        |        |
C                                  |_________|_________|________|________|

C .......................................................................

      USE PIOMAPS_MODULE

        IMPLICIT  NONE

C INCLUDE FILES

      INCLUDE 'PIOGRID.EXT'      ! Parallel grid dimensions.
      INCLUDE 'PIOVARS.EXT'      ! Parameters for parallel implementation.
c     INCLUDE 'PIOMAPS.EXT'      ! Parallel processor-to-subdomain maps.
      INCLUDE 'IODECL3.EXT'      ! M3IO definitions and declarations

C ARGUMENTS:

      CHARACTER*( * ), INTENT(IN) :: CALLER     ! Calling program name.
      INTEGER, INTENT(IN) :: GL_NROWS   ! Number of rows in entire grid.
      INTEGER, INTENT(IN) :: GL_NCOLS   ! Number of columns in entire grid.
      INTEGER, INTENT(IN) :: NLAYS      ! Number of layers in entire grid.
      INTEGER, INTENT(IN) :: NTHIK      ! Cell thickness of grid boundary.
      INTEGER, INTENT(IN) :: NPROW      ! Number of processors across grid rows.
      INTEGER, INTENT(IN) :: NPCOL      ! Number of processors across grid columns.
      INTEGER, INTENT(IN) :: NROWS      ! Row dimension of local-processor arrays.
      INTEGER, INTENT(IN) :: NCOLS      ! Column dimension of local-processor arrays.
      INTEGER, INTENT(IN) :: NPROCS     ! Number of processors.
      INTEGER, INTENT(IN) :: MYPE       ! Local processor id.

C EXTERNAL FUNCTIONS:

      EXTERNAL      INITM3IO, SUBDMAP, WRSUBMAP ! Parallel M3IO library.
!     EXTERNAL      PM3WARN, PM3EXIT            ! Parallel M3IO library.

C LOCAL VARIABLES:

      INTEGER I                  ! Loop index.
      INTEGER J                  ! Loop index.
      INTEGER LOCI               ! Row index of MYPE in Cartesian coordinate.
      INTEGER LOCJ               ! Col. index of MYPE in Cartesian coordinate.
      INTEGER POS                ! Index into neighborhood conversion table.
      INTEGER CONV( 8 )          ! Processor neighborhood conversion table.
      INTEGER IERROR             ! Error code.
      INTEGER LOGDEV             ! FORTRAN unit number for log file.
      CHARACTER*80 MSG           ! For message issued from M3WARN

C   Equivalence of the conversion table:
C
C   (LOCI+1, LOCJ-1) (LOCI+1, LOCJ) (LOCI+1, LOCJ+1)                8  1  2
C   ( LOCI,  LOCJ-1) ( LOCI,  LOCJ) ( LOCI,  LOCJ+1) equivalent to  7     3
C   (LOCI-1, LOCJ-1) (LOCI-1, LOCJ) (LOCI-1, LOCJ+1)                6  5  4
      DATA CONV / 8, 1, 2, 7, 3, 6, 5, 4 /

C .......................................................................
C     begin function PIO_INIT

C Initialize return value and error code.
      PIO_INIT = .TRUE.
      IERROR = 0

C Set COMMON block variables.
      NUMPROCS = NPROCS      ! Number of processors.
      MY_PE = MYPE           ! Local processor id.
      IO_PE = 0              ! I/O processor id.
      GNROWS = GL_NROWS      ! Number of rows in global grid.
      GNCOLS = GL_NCOLS      ! Number of columns in global grid.
      GNLAYS = NLAYS         ! Number of layers in global grid.
      BTHICK = NTHIK         ! Cell thickness of grid boundary.
      NUMROWS = NROWS        ! Number of rows in local subgrid.
      NUMCOLS = NCOLS        ! Number of columns in local subgrid.
      NPROWD = NPROW         ! Number of processors across grid rows.
      NPCOLD = NPCOL         ! Number of processors across grid columns.

C Compute processor neighborhood.

      LOCI = MY_PE / NPCOL
      LOCJ = MOD ( MY_PE, NPCOL )
      POS = 0
      DO I = LOCI+1, LOCI-1, -1
         DO J = LOCJ-1, LOCJ+1
            IF ( ( I .NE. LOCI ) .OR. ( J .NE. LOCJ ) ) THEN
               POS = POS + 1
               IF ( ( I .GE. 0 )     .AND.
     &              ( I .LT. NPROW ) .AND.
     &              ( J .GE. 0 )     .AND.
     &              ( J .LT. NPCOL ) ) THEN
                  NGB_PE( CONV( POS ) ) = I * NPCOL + J
               ELSE
                  NGB_PE( CONV( POS ) ) = -1
               END IF
            END IF
         END DO
      END DO

C Start up the I/O API on all processors.

!     CALL INITM3IO ( CALLER, MY_PE, IO_PE, LOGDEV )

C Allocate memory for processor-to-subdomain maps.

      IF (.NOT. ALLOCATED (NROWS_PE)) THEN
         ALLOCATE ( NROWS_PE  ( NUMPROCS ), STAT = IERROR )
         IF ( IERROR .NE. 0 ) THEN
            MSG = 'Error allocating NROWS_PE.'
            CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
            PIO_INIT = .FALSE.
            RETURN
         END IF

         ALLOCATE ( NCOLS_PE  ( NUMPROCS ), STAT = IERROR )
         IF ( IERROR .NE. 0 ) THEN
            MSG = 'Error allocating NCOLS_PE.'
            CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
            PIO_INIT = .FALSE.
            RETURN
         END IF

         ALLOCATE ( ROWSX_PE  ( 2, NUMPROCS ), STAT = IERROR )
         IF ( IERROR .NE. 0 ) THEN
            MSG = 'Error allocating ROWSX_PE.'
            CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
            PIO_INIT = .FALSE.
            RETURN
         END IF

         ALLOCATE ( COLSX_PE  ( 2, NUMPROCS ), STAT = IERROR )
         IF ( IERROR .NE. 0 ) THEN
            MSG = 'Error allocating COLSX_PE.'
            CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
            PIO_INIT = .FALSE.
            RETURN
         END IF

C Allocate memory for processor-to-subdomain write maps.

         ALLOCATE ( WR_NROWS_PE  ( NUMPROCS ), STAT = IERROR )
         IF ( IERROR .NE. 0 ) THEN
            MSG = 'Error allocating WR_NROWS_PE.'
            CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
            PIO_INIT = .FALSE.
            RETURN
         END IF

         ALLOCATE ( WR_NCOLS_PE  ( NUMPROCS ), STAT = IERROR )
         IF ( IERROR .NE. 0 ) THEN
            MSG = 'Error allocating WR_NCOLS_PE.'
            CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
            PIO_INIT = .FALSE.
            RETURN
         END IF

         ALLOCATE ( WR_ROWSX_PE  ( 2, NUMPROCS ), STAT = IERROR )
         IF ( IERROR .NE. 0 ) THEN
            MSG = 'Error allocating WR_ROWSX_PE.'
            CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
            PIO_INIT = .FALSE.
            RETURN
         END IF

         ALLOCATE ( WR_COLSX_PE  ( 2, NUMPROCS ), STAT = IERROR )
         IF ( IERROR .NE. 0 ) THEN
            MSG = 'Error allocating WR_COLSX_PE.'
            CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
            PIO_INIT = .FALSE.
            RETURN
         END IF

C Allocate memory for processor-to-subdomain read maps.

         ALLOCATE ( RD_NROWS_PE  ( NUMPROCS ), STAT = IERROR )
         IF ( IERROR .NE. 0 ) THEN
            MSG = 'Error allocating RD_NROWS_PE.'
            CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
            PIO_INIT = .FALSE.
            RETURN
         END IF

         ALLOCATE ( RD_NCOLS_PE  ( NUMPROCS ), STAT = IERROR )
         IF ( IERROR .NE. 0 ) THEN
            MSG = 'Error allocating RD_NCOLS_PE.'
            CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
            PIO_INIT = .FALSE.
            RETURN
         END IF

         ALLOCATE ( RD_ROWSX_PE  ( 2, NUMPROCS ), STAT = IERROR )
         IF ( IERROR .NE. 0 ) THEN
            MSG = 'Error allocating RD_ROWSX_PE.'
            CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
            PIO_INIT = .FALSE.
            RETURN
         END IF

         ALLOCATE ( RD_COLSX_PE  ( 2, NUMPROCS ), STAT = IERROR )
         IF ( IERROR .NE. 0 ) THEN
            MSG = 'Error allocating RD_COLSX_PE.'
            CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
            PIO_INIT = .FALSE.
            RETURN
         END IF
      END IF

C Calculate processor-to-subdomain maps

      CALL SUBDMAP ( NUMPROCS, GL_NROWS, GL_NCOLS, NLAYS,
     &               NPCOL, NPROW, NROWS_PE, NCOLS_PE,
     &               ROWSX_PE, COLSX_PE, MAXCELLS, IERROR )
      IF ( IERROR .NE. 0 ) THEN
         MSG = 'Error in SUBDMAP'
         CALL M3WARN( 'PIO_INIT', 0, 0, MSG )
         PIO_INIT = .FALSE.
         RETURN
      END IF

C Write out processor-to-subdomain map

      IF ( MY_PE .EQ. IO_PE ) THEN
         CALL WRSUBMAP ( NUMPROCS, NROWS_PE, NCOLS_PE, ROWSX_PE, COLSX_PE )
      END IF

C Set number of rows and columns for (this) local processor

      MY_NROWS = NROWS_PE( MY_PE+1 )   ! COMMON block
      MY_NCOLS = NCOLS_PE( MY_PE+1 )   ! COMMON block

      RETURN
      END
