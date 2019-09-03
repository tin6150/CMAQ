      SUBROUTINE GET_READ_MAP( NP, NPR, NPC, GNROWS, GNCOLS,
     &                         NROWS3D, NCOLS3D, NLAYS3D,
     &                         NROWS_PE, NCOLS_PE, ROWSX_PE, COLSX_PE,
     &                         RD_NROWS_PE, RD_NCOLS_PE,
     &                         RD_ROWSX_PE, RD_COLSX_PE )
C.....................................................................
C
C  PURPOSE:  Determine the processor-to-grid map for the grid
C            to be read.
C
C  NOTE: This subroutine is an exact copy of GET_WRITE_MAP except that
C        the name of the subroutine has been changed to
C        GET_READ_MAP. The copy was made by Lucas A. J. Bastien when
C        creating the subroutine PREAD3. Also WR_* variables were
C        renamed RD_*.
C
C  REVISION HISTORY:
C       Original version  1/1999 by Al Bourgeois, to allow pwrite3 to
C              write output on a subgrid.
C       Modified 08/06/1999 by Al Bourgeois to make this a subroutine
C              instead of a function.
C       Modified 10/08/01 by David Wong
C         -- added a missing variable IERR in the SUBDMAP calling arguments
C       Modified 12/31/02 by David Wong
C         -- extended to handle dot file
C
C
C  ARGUMENT LIST DESCRIPTION:
C  IN:
C     INTEGER  NP                    ! Number of processors.
C     INTEGER  NPR                   ! Number of processors across grid rows.
C     INTEGER  NPC                   ! Number of processors across grid cols.
C     INTEGER  GNROWS                ! Row dimension of global domain.
C     INTEGER  GNCOLS                ! Column dimension of global domain.
C     INTEGER  NROWS3D               ! Row dimension of file variables.
C     INTEGER  NCOLS3D               ! Column dimension of file variables.
C     INTEGER  NLAYS3D               ! Layer dimension of file variable.
C     INTEGER  NROWS_PE(NP)          ! Number rows in each processor.
C     INTEGER  NCOLS_PE(NP)          ! Number columns in each processor.
C     INTEGER  ROWSX_PE(2,NP)        ! Row range for each PE.
C     INTEGER  COLSX_PE(2,NP)        ! Column range for each PE.
C
C  OUT:
C     INTEGER  RD_NROWS_PE(NP)       ! No. rows each PE of subgrid to read.
C     INTEGER  RD_NCOLS_PE(NP)       ! No. cols each PE of subgrid to read.
C     INTEGER  RD_ROWSX_PE(2,NP)     ! Row range each PE of subgrid to read.
C     INTEGER  RD_COLSX_PE(2,NP)     ! Col range each PE of subgrid to read.
C
C
C  LOCAL VARIABLE DESCRIPTION:  see below
C
C  CALLS: SUBDMAP
C
C........................................................................
C
        IMPLICIT  NONE
C
C.......   ARGUMENTS:

      INTEGER  NP                    ! Number of processors.
      INTEGER  NPR                   ! Number of processors across grid rows.
      INTEGER  NPC                   ! Number of processors across grid cols.
      INTEGER  GNROWS                ! Row dimension of global domain.
      INTEGER  GNCOLS                ! Column dimension of global domain.
      INTEGER  NROWS3D               ! Row dimension of file variables.
      INTEGER  NCOLS3D               ! Column dimension of file variables.
      INTEGER  NLAYS3D               ! Layer dimension of file variable.
      INTEGER  NROWS_PE(NP)          ! Number rows in each processor.
      INTEGER  NCOLS_PE(NP)          ! Number columns in each processor.
      INTEGER  ROWSX_PE(2,NP)        ! Row range for each PE.
      INTEGER  COLSX_PE(2,NP)        ! Column range for each PE.
      INTEGER  RD_NROWS_PE(NP)       ! No. rows each PE of subgrid to read.
      INTEGER  RD_NCOLS_PE(NP)       ! No. cols each PE of subgrid to read.
      INTEGER  RD_ROWSX_PE(2,NP)     ! Row range each PE of subgrid to read.
      INTEGER  RD_COLSX_PE(2,NP)     ! Col range each PE of subgrid to read.

C
C.......   LOCAL VARIABLES:

      INTEGER      I             ! Loop index.
      INTEGER      IDUMMY        ! Dummy argument to SUBDMAP, not used.]
      INTEGER      IERR          ! Return Error code

C........................................................................
C     begin subroutine GET_READ_MAP
C

C......   Determine the processor-to-subdomain mapping for the grid to
C......   be read. If the file variables to be read are defined on the
C......   entire (global) domain, load the previously defined
C......   decomposition map. Otherwise, get the new mapping on the
C......   subgrid.

c     IF( NROWS3D*NCOLS3D .EQ. GNROWS*GNCOLS ) THEN
      IF (( NROWS3D .EQ. GNROWS) .AND. ( NCOLS3D .EQ. GNCOLS )) THEN

C......   Load the full-grid processor-to-subdomain mapping.

         DO I = 1, NP
           RD_NROWS_PE(I) = NROWS_PE(I)
           RD_NCOLS_PE(I) = NCOLS_PE(I)
           RD_ROWSX_PE(1,I) = ROWSX_PE(1,I)
           RD_ROWSX_PE(2,I) = ROWSX_PE(2,I)
           RD_COLSX_PE(1,I) = COLSX_PE(1,I)
           RD_COLSX_PE(2,I) = COLSX_PE(2,I)
         END DO

      ELSE IF (( NROWS3D .EQ. GNROWS+1) .AND. ( NCOLS3D .EQ. GNCOLS+1 )) THEN

C......   Load the dot full-grid processor-to-subdomain mapping.

         RD_NCOLS_PE = NCOLS_PE
         RD_COLSX_PE = COLSX_PE
         RD_COLSX_PE = COLSX_PE
         RD_NROWS_PE = NROWS_PE
         RD_ROWSX_PE = ROWSX_PE
         RD_ROWSX_PE = ROWSX_PE

         DO I = NPC, NP, NPC
           RD_NCOLS_PE(I) = NCOLS_PE(I) + 1
           RD_COLSX_PE(2,I) = COLSX_PE(2,I) + 1
         END DO

         DO I = NP, NP-NPC+1, -1
           RD_NROWS_PE(I) = NROWS_PE(I) + 1
           RD_ROWSX_PE(2,I) = ROWSX_PE(2,I) + 1
         END DO

      ELSE

C......   Get the subgrid processor-to_subdomain mapping.

C.......   Calculate processor-to-subdomain maps.
        CALL SUBDMAP( NP, NROWS3D, NCOLS3D, NLAYS3D, NPC, NPR,
     &                RD_NROWS_PE, RD_NCOLS_PE,
     &                RD_ROWSX_PE, RD_COLSX_PE, IDUMMY, IERR)

      END IF


      RETURN
      END
