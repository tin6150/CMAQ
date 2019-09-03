 
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

      SUBROUTINE HDIFF_ADJ (LGRID, JDATE, JTIME, TSTEP)

C-----------------------------------------------------------------------
C
C     PURPOSE: perform discrete horizontal diffusion adjoint
C     calculations. This is a parallel version and it directly calls MPI
C     functions. It is actually a "fake" parallel version, as only one
C     processor performs the majority of the calculations. This
C     processor collects data from other processors, does the
C     calculations, and send the update values back to each
C     processor. This subroutine was written because the original
C     HDIFF_ADJ routine provided in the CMAQ-v4.5-ADJ code did not work
C     when running CMAQ in parallel with more than one processor. The
C     "fake" parallelism was a quick solution to make this subroutine
C     work in parallel environments.
C
C     NOTES: data is exchanged between processors for each species and
C     each vertical layer.
C 
C     REVISION HISTORY:
C     - Kumaresh Singh & Adrian Sandu (April 2007): original version.
C     - Lucas A. J. Bastien (June 2015): Implemented "fake" parallelism
C       and cleaned up unused variables.
C
C-----------------------------------------------------------------------
      
C     Modules

      USE GRID_CONF             ! horizontal & vertical domain specifications
      USE CGRID_SPCS            ! CGRID species number and offsets
      USE SUBST_MODULES         ! stenex
      USE SWAP_SANDIA

      IMPLICIT NONE

C     Include files

      INCLUDE SUBST_GC_DIFF     ! gas chem diffusion species and map table
      INCLUDE SUBST_AE_DIFF     ! aerosol diffusion species and map table
      INCLUDE SUBST_NR_DIFF     ! non-react diffusion species and map table
      INCLUDE SUBST_TR_DIFF     ! tracer diffusion species and map table
      INCLUDE SUBST_CONST       ! constants
      INCLUDE SUBST_IOPARMS     ! I/O parameters definitions
      INCLUDE SUBST_IOFDESC     ! file header data structure
      INCLUDE SUBST_IODECL      ! I/O definitions and declarations
      INCLUDE SUBST_MPICH

C     Dummy arguments
      
      REAL, POINTER, INTENT(INOUT) :: LGRID( :,:,:,: )
      INTEGER, INTENT(IN) :: JDATE      ! current model date (YYYYDDD)
      INTEGER, INTENT(IN) :: JTIME      ! current model time (HHMMSS)
      INTEGER, INTENT(IN) :: TSTEP( 2 ) ! time step vector (HHMMSS)
                                        ! TSTEP(1) = output time step
                                        ! TSTEP(2) = synchronization time  step
C     External functions

      INTEGER, EXTERNAL ::  TIME2SEC
      
C     Local variables (general)

      CHARACTER( 16 )   :: PNAME = "HDIFF_ADJ"
      LOGICAL, SAVE     :: FIRSTIME = .TRUE.
      INTEGER, SAVE     :: LOGDEV
      CHARACTER(LEN=96) :: MSG
      INTEGER           :: STATUS

C     Local variables (space and time steps)

      REAL       :: DT     ! diffusion time step (seconds)
      REAL       :: DTSEC  ! synchronization time step (seconds)
      INTEGER    :: NSTEPS ! number of diffusion time steps
      REAL       :: DX1    ! dx1 (meters)
      REAL       :: DX2    ! dx2 (meters)
      REAL, SAVE :: RDX1S  ! reciprocal dx1*dx1
      REAL, SAVE :: RDX2S  ! reciprocal dx2*dx2
      REAL       :: DTDX1S ! dt/dx1**2
      REAL       :: DTDX2S ! dt/dx2**2
      INTEGER    :: FDATE  ! interpolation date
      INTEGER    :: FTIME  ! interpolation time

C     Local variables (species mappings)

      INTEGER, PARAMETER :: N_SPC_DIFF = N_GC_DIFF + N_AE_DIFF +
     &                                   N_NR_DIFF + N_TR_DIFF
      INTEGER, SAVE :: DIFF_MAP(N_SPC_DIFF) ! global diff map to LGRID

C     Local variables (arrays for data local to each processor)

      REAL :: RHOJ(0:NCOLS+1, 0:NROWS+1, NLAYS) ! density X Jacobian
      REAL :: RK11(NCOLS+1,NROWS+1,NLAYS) ! RHOJ at x1 cell face, reused
                                          ! as 11 eddy diffusion factor
      REAL :: RK22(NCOLS+1,NROWS+1,NLAYS) ! RHOJ at x2 cell face, reused
                                          ! as 22 eddy diffusion factor
      REAL :: K11BAR3D (NCOLS+1,NROWS+1,NLAYS) ! average Cx11 eddy
                                               ! diffusion coefficient
      REAL :: K22BAR3D (NCOLS+1,NROWS+1,NLAYS) ! average Cx22 eddy
                                               ! diffusion coefficient

C     Local variables (global arrays for the processor doing the heavy
C     lifting)

      REAL, ALLOCATABLE, SAVE :: CONC_GL(:,:)
      REAL, ALLOCATABLE, SAVE :: LGRID_GL(:,:)
      REAL, ALLOCATABLE, SAVE :: RK11_GL(:,:)
      REAL, ALLOCATABLE, SAVE :: RK22_GL(:,:)
      REAL, ALLOCATABLE, SAVE :: RHOJ_GL(:,:)

C     Local variables (loops variables)

      INTEGER :: C, R, L, S, V, N, P ! loop variables
      INTEGER :: D2C
      INTEGER, SAVE :: STARTROW, ENDROW
      INTEGER, SAVE :: STARTCOL, ENDCOL

C     Local variables (MPI communication). Certain variables such as
C     some of the MPI tags were inspired from subroutine
C     .../PARIO/pwrgrdd.f

      INTEGER, SAVE :: NPROCS
      INTEGER, PARAMETER :: PE_CALC = 0 ! The processor that does the
                                        ! heavy lifting
      INTEGER :: MPI_ERR
      INTEGER :: MPI_STATUS(MPI_STATUS_SIZE)
      INTEGER :: WHO, C0, R0, NC, NR, LOC
      INTEGER, PARAMETER :: TAG1 = 901 ! MPI message tag: processor ID
      INTEGER, PARAMETER :: TAG2 = 902 ! MPI message tag: data array
      INTEGER, PARAMETER :: TAG3 = 903 ! MPI message tag: array size
      INTEGER :: BUFF_SIZE
      REAL, ALLOCATABLE, SAVE :: BUFF(:)

C     Interface

      INTERFACE
         SUBROUTINE RHO_J ( JDATE, JTIME, TSTEP, RHOJ )
            IMPLICIT NONE
            INTEGER, INTENT( IN ) :: JDATE, JTIME, TSTEP( 2 )
            REAL, INTENT( OUT )   :: RHOJ( :,:,: )
         END SUBROUTINE RHO_J
         SUBROUTINE HCDIFF3D ( JDATE, JTIME, K11BAR, K22BAR, DT )
            IMPLICIT NONE
            INTEGER, INTENT( IN ) :: JDATE, JTIME
            REAL, INTENT( OUT )   :: K11BAR( :,:,: ), K22BAR( :,:,: )
            REAL, INTENT( OUT )   :: DT
         END SUBROUTINE HCDIFF3D
      END INTERFACE
 
C     Main body starts here

      IF ( FIRSTIME ) THEN

         FIRSTIME = .FALSE.
         LOGDEV = INIT3()

C     Double-check the processor situation

         CALL MPI_COMM_SIZE(MPI_COMM_WORLD, NPROCS, MPI_ERR)
         IF (MPI_ERR .NE. 0) THEN
            MSG = "Error during call to MPI_COMM_SIZE"
            CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF
         IF (NPROCS .NE. NPCOL*NPROW) THEN
            MSG = "Discrepancy between NPROCS and NPCOL*NPROW"
            CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

C     Allocate arrays if I'm the processor that is doing the
C     heavy-lifting

         IF (MYPE .EQ. PE_CALC) THEN

            ALLOCATE(CONC_GL(0:GL_NCOLS+1, 0:GL_NROWS+1),
     &               LGRID_GL(GL_NCOLS, GL_NROWS),
     &               RK11_GL(GL_NCOLS+1, GL_NROWS+1),
     &               RK22_GL(GL_NCOLS+1, GL_NROWS+1),
     &               RHOJ_GL(GL_NCOLS, GL_NROWS),  STAT=STATUS)
            IF (STATUS .NE. 0) THEN
               MSG = "One or more *_GL array memory allocation failed"
               CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
            END IF

         END IF

C     The array BUFF will be used by every processor to send and receive
C     data. We allocate it such that it is big enough for any array we
C     will be communicationg. The +2 below is +1 (normal n=start-end+1)
C     +1 because of the dimension of the RK** arrays to be sent

         BUFF_SIZE = -1
         DO P=1, NPROCS
            BUFF_SIZE = MAX(BUFF_SIZE,
     &           (COLSX_PE(2,P)-COLSX_PE(1,P)+2)*
     &           (ROWSX_PE(2,P)-ROWSX_PE(1,P)+2))
         END DO

         ALLOCATE (BUFF(BUFF_SIZE), STAT=STATUS)
         IF (STATUS .NE. 0) THEN
            MSG = "BUFF memory allocation failed"
            CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
         END IF

C     Get dx1 from COORD include file

         IF (GDTYP_GD .EQ. LATGRD3) THEN
            DX1 = DG2M * XCELL_GD
     &          * COS(PI180*(YORIG_GD + YCELL_GD*FLOAT(GL_NROWS/2)))
            DX2 = DG2M * YCELL_GD
         ELSE
            DX1 = XCELL_GD
            DX2 = YCELL_GD
         END IF

         RDX1S = 1.0 / (DX1 * DX1)
         RDX2S = 1.0 / (DX2 * DX2)

C     Get LGRID offsets
 
         CALL CGRID_MAP(NSPCSD, GC_STRT, AE_STRT, NR_STRT, TR_STRT)
 
C     Create global map to LGRID
 
         S = 0
         DO V = 1, N_GC_DIFF
            S = S + 1
            DIFF_MAP(S) = GC_STRT - 1 + GC_DIFF_MAP(V)
         END DO
         DO V = 1, N_AE_DIFF
            S = S + 1
            DIFF_MAP(S) = AE_STRT - 1 + AE_DIFF_MAP(V)
         END DO
         DO V = 1, N_NR_DIFF
            S = S + 1
            DIFF_MAP(S) = NR_STRT - 1 + NR_DIFF_MAP(V)
         END DO
         DO V = 1, N_TR_DIFF
            S = S + 1
            DIFF_MAP(S) = TR_STRT - 1 + TR_DIFF_MAP(V)
         END DO

C     Get start and end rows for RK** arrays and the like. Note that the
C     5th dummy argument (which is INTENT(OUT)) of SUBST_LOOP_INDEX is
C     not used in the rest of this subroutine, so I use the loop
C     variables R and C arbitrarily
            
         CALL SUBST_LOOP_INDEX ("R", 1, NROWS, 1, R, STARTROW, ENDROW)
         CALL SUBST_LOOP_INDEX ("C", 1, NCOLS, 1, C, STARTCOL, ENDCOL)

      END IF                    ! if firstime
                   
      DTSEC = FLOAT(TIME2SEC(TSTEP(2)))
      FDATE = JDATE
      FTIME = JTIME
 
C     Get the computational grid (rho X Jacobian) for this step

      CALL RHO_J(FDATE, FTIME, TSTEP, RHOJ)
      CALL SWAP3D(RHOJ(1,NROWS,1), RHOJ(1,0,1), NCOLS, 1, NLAYS,
     &            NCOLS+2, NROWS+2, SOUTH)
      CALL SWAP3D(RHOJ(NCOLS,1,1), RHOJ(0,1,1), 1, NROWS, NLAYS,
     &            NCOLS+2, NROWS+2, WEST)

C     Get face values for RHOJ (assumes dx1 = dx2)

      DO L = 1, NLAYS
         DO R = STARTROW, ENDROW
            DO C = STARTCOL, ENDCOL
               RK11(C,R,L) = 0.5 * (RHOJ(C,R,L) + RHOJ(C-1,R,L))
               RK22(C,R,L) = 0.5 * (RHOJ(C,R,L) + RHOJ(C,R-1,L))
            END DO
         END DO
      END DO

C     Get the contravariant eddy diffusivities

      CALL HCDIFF3D(FDATE, FTIME, K11BAR3D, K22BAR3D, DT)

C     Get number of steps based on eddy time
 
      NSTEPS = INT ( DTSEC / DT ) + 1
      DT = DTSEC / FLOAT( NSTEPS )
      WRITE(LOGDEV,1005) DT, NSTEPS

C     Prepare RK** arrays

      DTDX1S = DT * RDX1S
      DTDX2S = DT * RDX2S

      DO L = 1, NLAYS
         DO R = STARTROW, ENDROW
            DO C = STARTCOL, ENDCOL
               RK11(C,R,L) = RK11(C,R,L) * K11BAR3D(C,R,L) * DTDX1S
               RK22(C,R,L) = RK22(C,R,L) * K22BAR3D(C,R,L) * DTDX2S
            END DO
         END DO
      END DO

C     Loop over species, layers, nsteps

      IF (MYPE .EQ. PE_CALC) CONC_GL = 0.0

      DO L = 1, NLAYS
            
         DO S = 1, N_SPC_DIFF
            D2C = DIFF_MAP(S)
         
            C0 = COLSX_PE(1,MYPE+1)
            R0 = ROWSX_PE(1,MYPE+1)
            NC = COLSX_PE(2,MYPE+1) - C0 + 1
            NR = ROWSX_PE(2,MYPE+1) - R0 + 1

            IF (MYPE .EQ. PE_CALC) THEN

C     Heavy-lifter processor copies its local arrays to the global
C     arrays

               DO R = 1, NR
                  DO C = 1, NC
                     LGRID_GL(C0+C-1,R0+R-1) = LGRID(C,R,L,D2C)
                     RHOJ_GL(C0+C-1,R0+R-1) = RHOJ(C,R,L)
                  END DO
               END DO
               NR = ENDROW - STARTROW + 1
               NC = ENDCOL - STARTCOL + 1
               DO R = 1, NR
                  DO C = 1, NC
                     RK11_GL(C0+C-1,R0+R-1) = RK11(C,R,L)
                     RK22_GL(C0+C-1,R0+R-1) = RK22(C,R,L)
                  END DO
               END DO

C     Heavy-lifter processor receives the rest of the arrays from
C     other processors

               DO P = 1, NPROCS-1

                  CALL MPI_RECV(WHO, 1, MPI_INTEGER, MPI_ANY_SOURCE, 
     &                 TAG1, MPI_COMM_WORLD, MPI_STATUS, MPI_ERR)
                  IF (MPI_ERR .NE. 0) THEN
                     MSG = "MPI error receiving processor identity"
                     CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                  END IF

                  C0 = COLSX_PE(1,WHO+1)
                  R0 = ROWSX_PE(1,WHO+1)
                  NC = COLSX_PE(2,WHO+1) - C0 + 1
                  NR = ROWSX_PE(2,WHO+1) - R0 + 1
                  BUFF_SIZE = NR*NC

                  ! LGRID
                  CALL MPI_RECV(BUFF, BUFF_SIZE, MPI_REAL, WHO,
     &                 TAG2, MPI_COMM_WORLD, MPI_STATUS, MPI_ERR)
                  IF (MPI_ERR .NE. 0) THEN
                     MSG = "MPI error receiving data"
                     CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                  END IF
                  LOC = 0
                  DO R = 1, NR
                     DO C = 1, NC
                        LOC = LOC + 1
                        LGRID_GL(C0+C-1,R0+R-1) = BUFF(LOC)
                     END DO
                  END DO

C     The buffers that do not depend on S are communicated only once per
C     value of L

                  IF (S .EQ. 1) THEN

                     ! RHOJ
                     CALL MPI_RECV(BUFF, BUFF_SIZE, MPI_REAL, WHO,
     &                    TAG2, MPI_COMM_WORLD, MPI_STATUS, MPI_ERR)
                     IF (MPI_ERR .NE. 0) THEN
                        MSG = "MPI error receiving data"
                        CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                     END IF
                     LOC = 0
                     DO R = 1, NR
                        DO C = 1, NC
                           LOC = LOC + 1
                           RHOJ_GL(C0+C-1,R0+R-1) = BUFF(LOC)
                        END DO
                     END DO

                     ! Get Size of RK** arrays
                     CALL MPI_RECV(NR, 1, MPI_INTEGER, WHO,
     &                    TAG3, MPI_COMM_WORLD, MPI_STATUS, MPI_ERR)
                     IF (MPI_ERR .NE. 0) THEN
                        MSG = "MPI error receiving array size"
                        CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                     END IF
                     CALL MPI_RECV(NC, 1, MPI_INTEGER, WHO,
     &                    TAG3, MPI_COMM_WORLD, MPI_STATUS, MPI_ERR)
                     IF (MPI_ERR .NE. 0) THEN
                        MSG = "MPI error receiving array size"
                        CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                     END IF
                     BUFF_SIZE = NR*NC
                  
                     ! RK11
                     CALL MPI_RECV(BUFF, BUFF_SIZE, MPI_REAL, WHO,
     &                    TAG2, MPI_COMM_WORLD, MPI_STATUS, MPI_ERR)
                     IF (MPI_ERR .NE. 0) THEN
                        MSG = "MPI error receiving data"
                        CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                     END IF
                     LOC = 0
                     DO R = 1, NR
                        DO C = 1, NC
                           LOC = LOC + 1
                           RK11_GL(C0+C-1,R0+R-1) = BUFF(LOC)
                        END DO
                     END DO

                     ! RK22
                     CALL MPI_RECV(BUFF, BUFF_SIZE, MPI_REAL, WHO,
     &                    TAG2, MPI_COMM_WORLD, MPI_STATUS, MPI_ERR)
                     IF (MPI_ERR .NE. 0) THEN
                        MSG = "MPI error receiving data"
                        CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                     END IF
                     LOC = 0
                     DO R = 1, NR
                        DO C = 1, NC
                           LOC = LOC + 1
                           RK22_GL(C0+C-1,R0+R-1) = BUFF(LOC)
                        END DO
                     END DO

                  END IF        ! S .EQ. 1

               END DO           ! P loop

C     Heavy-lifter processor does the math

               DO N = NSTEPS, 1, -1

                  DO R = 1, GL_NROWS
                     DO C = 1, GL_NCOLS
                        CONC_GL(C,R-1) = CONC_GL(C,R-1) +
     &                       LGRID_GL(C,R) * RK22_GL(C,R)
                        CONC_GL(C,R+1) = CONC_GL(C,R+1) +
     &                       LGRID_GL(C,R) * RK22_GL(C,R+1)
                        CONC_GL(C-1,R) = CONC_GL(C-1,R) +
     &                       LGRID_GL(C,R) * RK11_GL(C,R)
                        CONC_GL(C+1,R) = CONC_GL(C+1,R) +
     &                       LGRID_GL(C,R) * RK11_GL(C+1,R)
                        CONC_GL(C,R) = CONC_GL(C,R) + LGRID_GL(C,R) *
     &                       (RHOJ_GL(C,R) - (RK11_GL(C+1,R)+RK11_GL(C,R))
     &                       - (RK22_GL(C,R+1)+RK22_GL(C,R)))
                        LGRID_GL(C,R) = 0.
                     END DO
                  END DO

                  C = GL_NCOLS
                  DO R = 1, GL_NROWS
                     CONC_GL(C,R) = CONC_GL(C,R) + CONC_GL(C+1,R)
                     CONC_GL(C+1,R) = 0.
                  END DO
                  C = 1
                  DO R = 1, GL_NROWS
                     CONC_GL(C,R) = CONC_GL(C,R) + CONC_GL(C-1,R)
                     CONC_GL(C-1,R) = 0.
                  END DO
                  R = GL_NROWS
                  DO C = 1, GL_NCOLS
                     CONC_GL(C,R) = CONC_GL(C,R) + CONC_GL(C,R+1)
                     CONC_GL(C,R+1) = 0.
                  END DO
                  R = 1
                  DO C = 1, GL_NCOLS
                     CONC_GL(C,R) = CONC_GL(C,R) + CONC_GL(C,R-1)
                     CONC_GL(C,R-1) = 0.
                  END DO            
                  
               END DO           ! N loop
               
               DO R = 1, GL_NROWS
                  DO C = 1, GL_NCOLS
                     ! TODO REMOVE FIRST TERM OF ADDITION? I THINK
                     ! LGRID=0 AT THIS POINT
                     LGRID_GL(C,R)=LGRID_GL(C,R)+CONC_GL(C,R)/RHOJ_GL(C,R)
                     CONC_GL(C,R) = 0.
                  END DO
               END DO
               
            ELSE
               
C     Other processors send their data

               CALL MPI_SEND(MYPE, 1, MPI_INTEGER, PE_CALC, TAG1,
     &              MPI_COMM_WORLD, MPI_ERR)
               IF (MPI_ERR .NE. 0) THEN
                  MSG = "MPI error sending processor identity."
                  CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
               END IF

               BUFF_SIZE = NR*NC

               ! LGRID
               LOC = 0
               DO R = 1, NR
                  DO C = 1, NC
                     LOC = LOC + 1
                     BUFF(LOC) = LGRID(C,R,L,D2C)
                  END DO
               END DO
               CALL MPI_SEND(BUFF, BUFF_SIZE, MPI_REAL, PE_CALC, TAG2,
     &              MPI_COMM_WORLD, MPI_ERR)
               IF (MPI_ERR .NE. 0) THEN
                  MSG = "MPI error sending data."
                  CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
               END IF

C     The buffers that do not depend on S are communicated only once per
C     value of L

               IF (S .EQ. 1) THEN
                  
                  ! RHOJ
                  LOC = 0
                  DO R = 1, NR
                     DO C = 1, NC
                        LOC = LOC + 1
                        BUFF(LOC) = RHOJ(C,R,L)
                     END DO
                  END DO
                  CALL MPI_SEND(BUFF, BUFF_SIZE, MPI_REAL, PE_CALC, TAG2,
     &                 MPI_COMM_WORLD, MPI_ERR)
                  IF (MPI_ERR .NE. 0) THEN
                     MSG = "MPI error sending data."
                     CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                  END IF

                  ! Send RK** array size
                  NR = ENDROW - STARTROW + 1
                  NC = ENDCOL - STARTCOL + 1
                  BUFF_SIZE = NR*NC
                  CALL MPI_SEND(NR, 1, MPI_INTEGER, PE_CALC, TAG3,
     &                 MPI_COMM_WORLD, MPI_ERR)
                  IF (MPI_ERR .NE. 0) THEN
                     MSG = "MPI error sending array size."
                     CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                  END IF
                  CALL MPI_SEND(NC, 1, MPI_INTEGER, PE_CALC, TAG3,
     &                 MPI_COMM_WORLD, MPI_ERR)
                  IF (MPI_ERR .NE. 0) THEN
                     MSG = "MPI error sending array size."
                     CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                  END IF

                  ! RK11
                  LOC = 0
                  DO R = 1, NR
                     DO C = 1, NC
                        LOC = LOC + 1
                        BUFF(LOC) = RK11(C,R,L)
                     END DO
                  END DO
                  CALL MPI_SEND(BUFF, BUFF_SIZE, MPI_REAL, PE_CALC, TAG2,
     &                 MPI_COMM_WORLD, MPI_ERR)
                  IF (MPI_ERR .NE. 0) THEN
                     MSG = "MPI error sending data."
                     CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                  END IF

                  ! RK22
                  LOC = 0
                  DO R = 1, NR
                     DO C = 1, NC
                        LOC = LOC + 1
                        BUFF(LOC) = RK22(C,R,L)
                     END DO
                  END DO
                  CALL MPI_SEND(BUFF, BUFF_SIZE, MPI_REAL, PE_CALC, TAG2,
     &                 MPI_COMM_WORLD, MPI_ERR)
                  IF (MPI_ERR .NE. 0) THEN
                     MSG = "MPI error sending data."
                     CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                  END IF

               END IF           ! S .EQ. 1

            END IF              ! Which processor

C     Wait for all processors at this point and then exhange the updated data

            CALL BARRIER()

            C0 = COLSX_PE(1,MYPE+1)
            R0 = ROWSX_PE(1,MYPE+1)
            NC = COLSX_PE(2,MYPE+1) - C0 + 1
            NR = ROWSX_PE(2,MYPE+1) - R0 + 1

            IF (MYPE .EQ. PE_CALC) THEN

               DO R = 1, NR
                  DO C = 1, NC
                     LGRID(C,R,L,D2C) = LGRID_GL(C0+C-1,R0+R-1)
                  END DO
               END DO

               DO P = 1, NPROCS-1

                  CALL MPI_RECV(WHO, 1, MPI_INTEGER, MPI_ANY_SOURCE, 
     &                 TAG1, MPI_COMM_WORLD, MPI_STATUS, MPI_ERR)
                  IF (MPI_ERR .NE. 0) THEN
                     MSG = "MPI error receiving processor identity."
                     CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                  END IF

                  C0 = COLSX_PE(1,WHO+1)
                  R0 = ROWSX_PE(1,WHO+1)
                  NC = COLSX_PE(2,WHO+1) - C0 + 1
                  NR = ROWSX_PE(2,WHO+1) - R0 + 1
                  BUFF_SIZE = NR*NC

                  LOC = 0
                  DO R = 1, NR
                     DO C = 1, NC
                        LOC = LOC + 1
                        BUFF(LOC) = LGRID_GL(C0+C-1,R0+R-1)
                     END DO
                  END DO

                  CALL MPI_SEND(BUFF, BUFF_SIZE, MPI_REAL, WHO, TAG2,
     &                 MPI_COMM_WORLD, MPI_ERR)
                  IF (MPI_ERR .NE. 0) THEN
                     MSG = "MPI error sending data."
                     CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
                  END IF

               END DO

            ELSE

               CALL MPI_SEND(MYPE, 1, MPI_INTEGER, PE_CALC, TAG1,
     &              MPI_COMM_WORLD, MPI_ERR)
               IF (MPI_ERR .NE. 0) THEN
                  MSG = "MPI error sending processor identity."
                  CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
               END IF

               CALL MPI_RECV(BUFF, BUFF_SIZE, MPI_REAL, PE_CALC,
     &              TAG2, MPI_COMM_WORLD, MPI_STATUS, MPI_ERR)
               IF (MPI_ERR .NE. 0) THEN
                  MSG = "MPI error receiving data from processor."
                  CALL M3EXIT (PNAME, JDATE, JTIME, MSG, XSTAT2)
               END IF

               LOC = 0
               DO R = 1, NR
                  DO C = 1, NC
                     LOC = LOC + 1
                     LGRID(C,R,L,D2C) = BUFF(LOC)
                  END DO
               END DO

            END IF

C     Wait for everybody before beginning the next step

            CALL BARRIER()

         END DO                 ! S loop
      END DO                    ! L loop
      
      RETURN
1005  FORMAT( / 5X, 'H-eddy DT & integration steps: ', 1PE15.7, I8 )
      END

