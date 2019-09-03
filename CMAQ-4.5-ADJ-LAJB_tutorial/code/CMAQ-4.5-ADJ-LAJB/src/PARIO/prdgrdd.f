C     Portions of Models-3/CMAQ software were developed or based on
C     information from various groups: Federal Government employees,
C     contractors working on a United States Government contract, and
C     non-Federal sources (including research institutions).  These
C     research institutions have given the Government permission to use,
C     prepare derivative works, and distribute copies of their work in
C     Models-3/CMAQ to the public and to permit others to do so.  EPA
C     therefore grants similar permissions for use of the Models-3/CMAQ
C     software, but users are requested to provide copies of derivative
C     works to the Government without restrictions as to use by others.
C     Users are responsible for acquiring their own copies of commercial
C     software associated with Models-3/CMAQ and for complying with
C     vendor requirements.  Software copyrights by the MCNC
C     Environmental Modeling Center are used with their permissions
C     subject to the above restrictions.
C
C     Author: Lucas A. J. Bastien (strongly inspired by PARIO/pwrgrdd.f,
C     with some code directly copied from it)

      LOGICAL FUNCTION PRDGRDD(FNAME, VNAME, JDATE, JTIME,
     &                         NCOLS3D, NROWS3D, NLAYS3D,
     &                         LAYER, BUFFER)
C.....................................................................
C
C  PURPOSE: Perform Models-3 file-read operation in a parallel
C           environment. Values for variable VARNAME are read from the
C           file by the primary I/O processor. Then the relevant
C           sections of the data are sent to the other processors via
C           MPI calls.
C
C  ARGUMENTS:
C   * FNAME: Logical name of file to read.
C   * VNAME: Name of variable to read.
C   * JDATE: Date to read (YYYYDDD)
C   * JTIME: Time to read (HHMMSS)
C   * NCOLS3D: Number of columns of file variables.
C   * NROWS3D: Number of rows of file variables.
C   * NLAYS3D: Number of layers of file variables.
C   * LAYER: Layer(s) to read (single layer or ALLAYS3 for all layers.
C   * BUFFER: Buffer to store the data being read.
C
C  RETURN VALUE: .TRUE. if everything goes as expected, .FALSE. otherwise.
C
C-----------------------------------------------------------------------

C     Modules

      USE PIOMAPS_MODULE

      IMPLICIT NONE

C Include Files

      INCLUDE "PARMS3.EXT"  ! I/O parameters definitions
      INCLUDE "IODECL3.EXT" ! I/O definitions and declarations
      INCLUDE "PIOVARS.EXT" ! Parameters for parallel environment
      INCLUDE "PIOGRID.EXT" ! Grid dimensions and decomposition
      INCLUDE 'mpif.h'      ! MPI definitions and parameters

C     Dummy arguments

      CHARACTER(LEN=16), INTENT(IN) :: FNAME, VNAME
      INTEGER, INTENT(IN) :: JDATE, JTIME
      INTEGER, INTENT(IN) :: NCOLS3D, NROWS3D, NLAYS3D
      INTEGER, INTENT(IN) :: LAYER
      REAL, INTENT(INOUT) :: BUFFER(NUMCOLS,NUMROWS,NLAYS3D)

C     Local variables

      CHARACTER(LEN=16) :: PNAME = "PRDGRDD"
      CHARACTER(LEN=96) :: MSG
      REAL, ALLOCATABLE :: BUFF_MPI(:), BUFF_ALL(:,:,:)
      INTEGER :: ERROR
      INTEGER :: LAY, NLAYS
      INTEGER :: NUMCOLS_MAX, NUMROWS_MAX
      INTEGER :: BUFF_SIZE
      INTEGER :: IL, IR, IC, IP, C0, R0, NC, NR
      INTEGER :: WHO, MPI_STATUS(MPI_STATUS_SIZE)
      INTEGER, PARAMETER :: TAG_WHO = 900, TAG_DATA = 901

C     ------------------------------------------------------------------

      PRDGRDD = .FALSE.

      IF (LAYER .EQ. ALLAYS3) THEN
         NLAYS = NLAYS3D
      ELSE
         NLAYS = 1
      END IF

C     Allocate array for MPI communication

      NUMCOLS_MAX = RD_NCOLS_PE(1)
      NUMROWS_MAX = RD_NROWS_PE(1)
      DO IP = 2, NUMPROCS
         NUMCOLS_MAX = MAX(NUMCOLS_MAX, RD_NCOLS_PE(IP))
         NUMROWS_MAX = MAX(NUMROWS_MAX, RD_NROWS_PE(IP))
      END DO

      ALLOCATE(BUFF_MPI(NUMCOLS_MAX*NUMROWS_MAX*NLAYS), STAT=ERROR)
      IF (ERROR .NE. 0) THEN
         MSG = "BUFF_MPI allocation failed"
         CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
         RETURN
      END IF

      IF (MY_PE .EQ. IO_PE) THEN

C     IO processor needs a buffer to read the whole array

         ALLOCATE(BUFF_ALL(NCOLS3D, NROWS3D, NLAYS), STAT=ERROR)
         IF (ERROR .NE. 0) THEN
            MSG = "BUFF_ALL allocation failed"
            CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
            RETURN
         END IF

C     IO processor reads the whole array

         IF (.NOT. READ3(FNAME, VNAME, LAYER, JDATE, JTIME,
     &        BUFF_ALL)) THEN
            MSG = "Reading " // VNAME // " from " // FNAME //
     &           " by IO processor failed"
            CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
            RETURN
         END IF

C     IO processor sends the data to all other processors

         DO IP = 2, NUMPROCS

            CALL MPI_RECV(WHO, 1, MPI_INTEGER, MPI_ANY_SOURCE,
     &           TAG_WHO, MPI_COMM_WORLD, MPI_STATUS, ERROR)
            IF (ERROR .NE. MPI_SUCCESS) THEN
               MSG = "Error when receiving processor ID"
               CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
               RETURN
            END IF

            C0 = RD_COLSX_PE(1,WHO+1)
            R0 = RD_ROWSX_PE(1,WHO+1)
            NC = RD_NCOLS_PE(WHO+1)
            NR = RD_NROWS_PE(WHO+1)

            BUFF_SIZE = 0
            DO IL = 1, NLAYS
               DO IR = 1, NR
                  DO IC = 1, NC
                     BUFF_SIZE = BUFF_SIZE + 1
                     BUFF_MPI(BUFF_SIZE) = BUFF_ALL(C0+IC-1,R0+IR-1,IL)
                  END DO
               END DO
            END DO

            CALL MPI_SEND(BUFF_MPI, BUFF_SIZE, MPI_REAL, WHO, TAG_DATA,
     &                    MPI_COMM_WORLD, ERROR)
            IF (ERROR .NE. MPI_SUCCESS) THEN
               MSG = "Error when sending data"
               CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
               RETURN
            END IF

         END DO

C     IO Processor retrieves its own section of the array

         C0 = RD_COLSX_PE(1,IO_PE+1)
         R0 = RD_ROWSX_PE(1,IO_PE+1)
         NC = RD_NCOLS_PE(IO_PE+1)
         NR = RD_NROWS_PE(IO_PE+1)

         DO IL = 1, NLAYS
            IF (LAYER .EQ. ALLAYS3) THEN
               LAY = IL
            ELSE
               LAY = LAYER
            END IF
            DO IR = 1, NR
               DO IC = 1, NC
                  BUFFER(IC,IR,LAY) = BUFF_ALL(C0+IC-1,R0+IR-1,IL)
               END DO
            END DO
         END DO

C     IO processor deallocates the buffer for the whole array
      DEALLOCATE(BUFF_ALL, STAT=ERROR)
      IF (ERROR .NE. 0) THEN
         MSG = "BUFF_ALL allocation failed"
         CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
         RETURN
      END IF

      ELSE

C     Non-IO processors receive the data

         CALL MPI_SEND(MY_PE, 1, MPI_INTEGER, IO_PE, TAG_WHO,
     &                 MPI_COMM_WORLD, ERROR)
         IF (ERROR .NE. MPI_SUCCESS) THEN
            MSG = "Error when sending processor ID"
            CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
            RETURN
         END IF

         C0 = RD_COLSX_PE(1,MY_PE+1)
         R0 = RD_ROWSX_PE(1,MY_PE+1)
         NC = RD_NCOLS_PE(MY_PE+1)
         NR = RD_NROWS_PE(MY_PE+1)
         BUFF_SIZE = NC * NR * NLAYS

         CALL MPI_RECV(BUFF_MPI, BUFF_SIZE, MPI_REAL, IO_PE,
     &        TAG_DATA, MPI_COMM_WORLD, MPI_STATUS, ERROR)
         IF (ERROR .NE. MPI_SUCCESS) THEN
            MSG = "Error when receiving data"
            CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
            RETURN
         END IF

         BUFF_SIZE = 0
         DO IL = 1, NLAYS
            IF (LAYER .EQ. ALLAYS3) THEN
               LAY = IL
            ELSE
               LAY = LAYER
            END IF
            DO IR = 1, NR
               DO IC = 1, NC
                  BUFF_SIZE = BUFF_SIZE + 1
                  BUFFER(IC,IR,LAY) = BUFF_MPI(BUFF_SIZE)
               END DO
            END DO
         END DO

      END IF ! IO processor or not

C     Deallocate array for MPI communication

      DEALLOCATE(BUFF_MPI, STAT=ERROR)
      IF (ERROR .NE. 0) THEN
         MSG = "BUFF_MPI deallocation failed"
         CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
         RETURN
      END IF

C     Wait for all the processors to be reach this point

      CALL MPI_BARRIER(MPI_COMM_WORLD, ERROR)
      IF (ERROR .NE. MPI_SUCCESS) THEN
         MSG = "Error in call of MPI_BARRIER"
         CALL PM3WARN(PNAME, JDATE, JTIME, MSG)
         RETURN
      END IF

C     If we got here, everything went well

      PRDGRDD = .TRUE.
      RETURN

      END FUNCTION PRDGRDD
